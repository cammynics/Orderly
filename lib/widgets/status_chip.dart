import 'package:flutter/material.dart';

import '../models/order_status.dart';
import '../utils/theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, this.onChanged, super.key});

  final OrderStatus status;
  final ValueChanged<OrderStatus>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = OrderlyTheme.statusColor(status);
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: OrderlyTheme.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onChanged != null) ...[
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: 16, color: OrderlyTheme.text),
          ],
        ],
      ),
    );
    if (onChanged == null) return chip;
    return PopupMenuButton<OrderStatus>(
      tooltip: 'Change order status',
      onSelected: onChanged,
      itemBuilder: (context) => OrderStatus.values
          .map((value) => PopupMenuItem(value: value, child: Text(value.label)))
          .toList(),
      child: Semantics(
        button: true,
        label: 'Status: ${status.label}',
        child: chip,
      ),
    );
  }
}
