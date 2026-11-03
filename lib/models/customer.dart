class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.orderCount,
    required this.totalSpent,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final int orderCount;
  final double totalSpent;

  factory Customer.fromMap(Map<String, Object?> map) => Customer(
    id: map['id']! as String,
    name: map['name']! as String,
    phone: map['phone']! as String,
    address: map['address'] as String? ?? '',
    orderCount: map['order_count'] as int? ?? 0,
    totalSpent: (map['total_spent'] as num? ?? 0).toDouble(),
  );
}
