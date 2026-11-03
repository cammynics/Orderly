import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../models/customer.dart';
import '../models/order.dart';
import '../models/status_event.dart';

class OrderRepository {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final directory = await getDatabasesPath();
    _database = await openDatabase(
      '$directory${Platform.pathSeparator}orderly.db',
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL UNIQUE,
            normalized_phone TEXT NOT NULL UNIQUE,
            address TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE orders (
            id TEXT PRIMARY KEY,
            order_number TEXT NOT NULL UNIQUE,
            customer_id TEXT NOT NULL REFERENCES customers(id),
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL CHECK(quantity > 0),
            unit_price REAL NOT NULL CHECK(unit_price >= 0),
            total REAL NOT NULL CHECK(total >= 0),
            order_date INTEGER NOT NULL,
            status TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE status_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
            status TEXT NOT NULL,
            changed_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE order_counter (
            id INTEGER PRIMARY KEY CHECK(id = 1),
            next_number INTEGER NOT NULL
          )
        ''');
        await db.insert('order_counter', {'id': 1, 'next_number': 1});
        await db.execute('CREATE INDEX orders_date_idx ON orders(order_date)');
        await db.execute('CREATE INDEX orders_status_idx ON orders(status)');
        await db.execute(
          'CREATE INDEX orders_customer_idx ON orders(customer_id)',
        );
      },
    );
    return _database!;
  }

  Future<List<Order>> getOrders() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone,
             c.address AS customer_address
      FROM orders o JOIN customers c ON c.id = o.customer_id
      ORDER BY o.order_date DESC, o.created_at DESC
    ''');
    return rows.map(Order.fromMap).toList(growable: false);
  }

  Future<List<Customer>> getCustomers() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.phone, c.address,
             COUNT(o.id) AS order_count,
             COALESCE(SUM(CASE WHEN o.status != 'cancelled' THEN o.total ELSE 0 END), 0) AS total_spent
      FROM customers c LEFT JOIN orders o ON o.customer_id = c.id
      GROUP BY c.id
      ORDER BY c.name COLLATE NOCASE
    ''');
    return rows.map(Customer.fromMap).toList(growable: false);
  }

  Future<List<StatusEvent>> getStatusHistory(String orderId) async {
    final db = await _db;
    final rows = await db.query(
      'status_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'changed_at ASC, id ASC',
    );
    return rows.map(StatusEvent.fromMap).toList(growable: false);
  }

  Future<Order> saveOrder(Order order) async {
    final db = await _db;
    return db.transaction((transaction) async {
      final now = DateTime.now();
      final customer = await transaction.query(
        'customers',
        where: 'normalized_phone = ?',
        whereArgs: [_normalizePhone(order.customerPhone)],
        limit: 1,
      );
      final customerId = customer.isEmpty
          ? order.customerId
          : customer.first['id']! as String;
      if (customer.isEmpty) {
        await transaction.insert('customers', {
          'id': customerId,
          'name': order.customerName.trim(),
          'phone': order.customerPhone.trim(),
          'normalized_phone': _normalizePhone(order.customerPhone),
          'address': order.customerAddress.trim(),
          'created_at': now.millisecondsSinceEpoch,
        });
      } else {
        await transaction.update(
          'customers',
          {
            'name': order.customerName.trim(),
            'phone': order.customerPhone.trim(),
            'address': order.customerAddress.trim(),
          },
          where: 'id = ?',
          whereArgs: [customerId],
        );
      }

      var number = order.orderNumber;
      if (number.isEmpty) {
        final counter = await transaction.query(
          'order_counter',
          where: 'id = 1',
          limit: 1,
        );
        final next = counter.first['next_number']! as int;
        await transaction.update('order_counter', {
          'next_number': next + 1,
        }, where: 'id = 1');
        number = 'ORD-${next.toString().padLeft(4, '0')}';
      }

      final previous = await transaction.query(
        'orders',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [order.id],
        limit: 1,
      );
      final saved = Order(
        id: order.id,
        orderNumber: number,
        customerId: customerId,
        customerName: order.customerName.trim(),
        customerPhone: order.customerPhone.trim(),
        customerAddress: order.customerAddress.trim(),
        productName: order.productName.trim(),
        quantity: order.quantity,
        unitPrice: order.unitPrice,
        total: order.quantity * order.unitPrice,
        orderDate: order.orderDate,
        status: order.status,
        notes: order.notes.trim(),
        createdAt: order.createdAt,
        updatedAt: now,
      );
      if (previous.isEmpty) {
        await transaction.insert('orders', saved.toMap());
      } else {
        await transaction.update(
          'orders',
          saved.toMap(),
          where: 'id = ?',
          whereArgs: [order.id],
        );
      }
      if (previous.isEmpty || previous.first['status'] != order.status.name) {
        await transaction.insert('status_history', {
          'order_id': order.id,
          'status': order.status.name,
          'changed_at': now.millisecondsSinceEpoch,
        });
      }
      return saved;
    });
  }

  Future<void> deleteOrder(String id) async {
    final db = await _db;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  String _normalizePhone(String phone) => phone.replaceAll(RegExp(r'\D'), '');
}
