import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/order_store.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../widgets/summary_card.dart';

enum SummaryPeriod { today, week, month, allTime }

extension SummaryPeriodLabel on SummaryPeriod {
  String get label => switch (this) {
    SummaryPeriod.today => 'Today',
    SummaryPeriod.week => 'This week',
    SummaryPeriod.month => 'This month',
    SummaryPeriod.allTime => 'All time',
  };
}

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _period = SummaryPeriod.allTime;

  @override
  Widget build(BuildContext context) => Consumer<OrderStore>(
    builder: (context, store, _) {
      if (store.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      final orders = store.orders.where(_isInPeriod).toList(growable: false);
      final sales = orders
          .where((order) => order.status != OrderStatus.cancelled)
          .fold<double>(0, (total, order) => total + order.total);
      final counts = <OrderStatus, int>{
        for (final status in OrderStatus.values)
          status: orders.where((order) => order.status == status).length,
      };
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(
            'A clear picture of your sales.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: OrderlyTheme.secondaryText),
          ),
          const SizedBox(height: 16),
          SegmentedButton<SummaryPeriod>(
            segments: SummaryPeriod.values
                .map(
                  (period) =>
                      ButtonSegment(value: period, label: Text(period.label)),
                )
                .toList(),
            selected: {_period},
            onSelectionChanged: (selection) =>
                setState(() => _period = selection.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(
                label: 'Total orders',
                value: '${orders.length}',
                icon: Icons.receipt_long_outlined,
              ),
              SummaryCard(
                label: 'Sales value',
                value: formatCurrency(sales),
                icon: Icons.payments_outlined,
                gradient: OrderlyTheme.accentGradient,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Orders by status',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final status in OrderStatus.values)
            _statusSummary(context, status, counts[status]!, orders.length),
        ],
      );
    },
  );

  bool _isInPeriod(Order order) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_period == SummaryPeriod.allTime) return true;
    late DateTime start;
    late DateTime end;
    switch (_period) {
      case SummaryPeriod.today:
        start = today;
        end = today.add(const Duration(days: 1));
      case SummaryPeriod.week:
        start = today.subtract(Duration(days: today.weekday - 1));
        end = start.add(const Duration(days: 7));
      case SummaryPeriod.month:
        start = DateTime(now.year, now.month);
        end = DateTime(now.year, now.month + 1);
      case SummaryPeriod.allTime:
        return true;
    }
    return !order.orderDate.isBefore(start) && order.orderDate.isBefore(end);
  }

  Widget _statusSummary(
    BuildContext context,
    OrderStatus status,
    int count,
    int total,
  ) {
    final color = OrderlyTheme.statusColor(status);
    final progress = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(status.label)),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
