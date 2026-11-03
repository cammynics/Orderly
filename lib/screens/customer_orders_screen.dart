import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../providers/order_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_card.dart';
import 'order_details_screen.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({required this.customer, super.key});

  final Customer customer;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(customer.name)),
    body: Consumer<OrderStore>(
      builder: (context, store, _) {
        final orders = store.orders
            .where((order) => order.customerId == customer.id)
            .toList(growable: false);
        if (orders.isEmpty) {
          return const EmptyState(
            title: 'No orders to show',
            message: 'Orders for this customer will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderCard(
                order: order,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OrderDetailsScreen(order: order),
                  ),
                ),
                onStatusChanged: (status) => store.updateStatus(order, status),
              ),
            );
          },
        );
      },
    ),
  );
}
