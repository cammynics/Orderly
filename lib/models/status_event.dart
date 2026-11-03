import 'order_status.dart';

class StatusEvent {
  const StatusEvent({required this.status, required this.changedAt});

  final OrderStatus status;
  final DateTime changedAt;

  factory StatusEvent.fromMap(Map<String, Object?> map) => StatusEvent(
    status: OrderStatusLabel.fromName(map['status']! as String),
    changedAt: DateTime.fromMillisecondsSinceEpoch(map['changed_at']! as int),
  );
}
