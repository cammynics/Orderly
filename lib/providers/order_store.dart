import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/order_repository.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/status_event.dart';

class OrderStore extends ChangeNotifier {
  OrderStore({OrderRepository? repository})
    : _repository = repository ?? OrderRepository();

  final OrderRepository _repository;
  final List<Order> _orders = [];
  final List<Customer> _customers = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Order> get orders => List.unmodifiable(_orders);
  List<Customer> get customers => List.unmodifiable(_customers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getOrders(),
        _repository.getCustomers(),
      ]);
      _orders
        ..clear()
        ..addAll(results[0] as List<Order>);
      _customers
        ..clear()
        ..addAll(results[1] as List<Customer>);
    } catch (_) {
      _errorMessage = 'Your orders could not be loaded. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> save({required Order draft}) async {
    _errorMessage = null;
    try {
      final saved = await _repository.saveOrder(draft);
      final index = _orders.indexWhere((order) => order.id == saved.id);
      if (index < 0) {
        _orders.insert(0, saved);
      } else {
        _orders[index] = saved;
      }
      await _refreshCustomers();
      _orders.sort((a, b) {
        final byDate = b.orderDate.compareTo(a.orderDate);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });
      notifyListeners();
      return saved;
    } catch (_) {
      _errorMessage =
          'The order could not be saved. Check the details and retry.';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateStatus(Order order, OrderStatus status) async {
    if (order.status == status) return;
    final changed = Order(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      productName: order.productName,
      quantity: order.quantity,
      unitPrice: order.unitPrice,
      total: order.total,
      orderDate: order.orderDate,
      status: status,
      notes: order.notes,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
    );
    await save(draft: changed);
  }

  Future<List<StatusEvent>> historyFor(String orderId) =>
      _repository.getStatusHistory(orderId);

  Future<void> delete(Order order) async {
    try {
      await _repository.deleteOrder(order.id);
      _orders.removeWhere((item) => item.id == order.id);
      await _refreshCustomers();
      notifyListeners();
    } catch (_) {
      _errorMessage = 'The order could not be deleted.';
      notifyListeners();
    }
  }

  Future<Order?> restore(Order order) async {
    final restored = await save(draft: order);
    return restored;
  }

  Future<void> _refreshCustomers() async {
    _customers
      ..clear()
      ..addAll(await _repository.getCustomers());
  }

  Order createDraft({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String productName,
    required int quantity,
    required double unitPrice,
    required DateTime orderDate,
    required OrderStatus status,
    required String notes,
    Order? existing,
  }) {
    final now = DateTime.now();
    return Order(
      id: existing?.id ?? const Uuid().v4(),
      orderNumber: existing?.orderNumber ?? '',
      customerId: existing?.customerId ?? const Uuid().v4(),
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: quantity * unitPrice,
      orderDate: orderDate,
      status: status,
      notes: notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
  }
}
