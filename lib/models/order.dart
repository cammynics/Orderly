import 'order_status.dart';

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.orderDate,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;
  final DateTime orderDate;
  final OrderStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'order_number': orderNumber,
    'customer_id': customerId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total': total,
    'order_date': orderDate.millisecondsSinceEpoch,
    'status': status.name,
    'notes': notes,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
  };

  factory Order.fromMap(Map<String, Object?> map) => Order(
    id: map['id']! as String,
    orderNumber: map['order_number']! as String,
    customerId: map['customer_id']! as String,
    customerName: map['customer_name']! as String,
    customerPhone: map['customer_phone']! as String,
    customerAddress: map['customer_address'] as String? ?? '',
    productName: map['product_name']! as String,
    quantity: map['quantity']! as int,
    unitPrice: (map['unit_price']! as num).toDouble(),
    total: (map['total']! as num).toDouble(),
    orderDate: DateTime.fromMillisecondsSinceEpoch(map['order_date']! as int),
    status: OrderStatusLabel.fromName(map['status']! as String),
    notes: map['notes'] as String? ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']! as int),
  );
}
