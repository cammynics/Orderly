import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/order_status.dart';
import '../models/status_event.dart';
import '../providers/order_store.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../widgets/status_chip.dart';
import 'order_form_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({required this.order, super.key});

  final Order order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Future<List<StatusEvent>>? _history;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _history ??= context.read<OrderStore>().historyFor(widget.order.id);
  }

  @override
  Widget build(BuildContext context) => Consumer<OrderStore>(
    builder: (context, store, _) {
      final order = store.orders.firstWhere(
        (item) => item.id == widget.order.id,
        orElse: () => widget.order,
      );
      return Scaffold(
        appBar: AppBar(
          title: Text(order.orderNumber),
          actions: [
            IconButton(
              tooltip: 'Edit order',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OrderFormScreen(order: order),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete order',
              onPressed: () => _delete(context, store, order),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _totalCard(context, order),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeading(context, 'Order status'),
                    const SizedBox(height: 14),
                    StatusChip(
                      status: order.status,
                      onChanged: (status) async {
                        await store.updateStatus(order, status);
                        if (!mounted) return;
                        setState(() {
                          _history = store.historyFor(order.id);
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    _sectionHeading(context, 'Status history'),
                    const SizedBox(height: 8),
                    FutureBuilder<List<StatusEvent>>(
                      future: _history,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final events = snapshot.data ?? const <StatusEvent>[];
                        if (events.isEmpty) {
                          return const Text('No status updates yet.');
                        }
                        return Column(
                          children: [
                            for (var index = 0; index < events.length; index++)
                              _timelineEvent(
                                context,
                                events[index],
                                index == events.length - 1,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeading(context, 'Customer'),
                    const SizedBox(height: 14),
                    _detailRow(
                      context,
                      Icons.person_outline,
                      order.customerName,
                    ),
                    _detailRow(
                      context,
                      Icons.phone_outlined,
                      order.customerPhone,
                    ),
                    if (order.customerAddress.isNotEmpty)
                      _detailRow(
                        context,
                        Icons.location_on_outlined,
                        order.customerAddress,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeading(context, 'Order details'),
                    const SizedBox(height: 14),
                    _detailRow(
                      context,
                      Icons.inventory_2_outlined,
                      order.productName,
                    ),
                    _detailRow(
                      context,
                      Icons.shopping_bag_outlined,
                      '${order.quantity} × ${formatCurrency(order.unitPrice)}',
                    ),
                    _detailRow(
                      context,
                      Icons.calendar_today_outlined,
                      formatDate(order.orderDate),
                    ),
                    if (order.notes.isNotEmpty)
                      _detailRow(context, Icons.notes_outlined, order.notes),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _totalCard(BuildContext context, Order order) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: OrderlyTheme.accentGradient,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.customerName,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: OrderlyTheme.surface),
        ),
        const SizedBox(height: 8),
        Text(
          formatCurrency(order.total),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: OrderlyTheme.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatDate(order.orderDate),
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: OrderlyTheme.surface),
        ),
      ],
    ),
  );

  Widget _sectionHeading(BuildContext context, String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w700),
  );

  Widget _detailRow(BuildContext context, IconData icon, String text) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: OrderlyTheme.secondaryText),
            const SizedBox(width: 11),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );

  Widget _timelineEvent(BuildContext context, StatusEvent event, bool isLast) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: OrderlyTheme.statusColor(event.status),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 35, color: OrderlyTheme.border),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.status.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateTime(event.changedAt),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: OrderlyTheme.secondaryText),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Future<void> _delete(
    BuildContext context,
    OrderStore store,
    Order order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete order?'),
        content: Text('Remove ${order.orderNumber} from your orders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await store.delete(order);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.orderNumber} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => store.restore(order),
        ),
      ),
    );
  }
}
