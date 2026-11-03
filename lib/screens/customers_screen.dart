import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../providers/order_store.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import 'customer_orders_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<OrderStore>(
    builder: (context, store, _) {
      if (store.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (store.customers.isEmpty) {
        return const EmptyState(
          title: 'Your customers will appear here',
          message: 'Save an order to start building your customer list.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: store.customers.length,
        itemBuilder: (context, index) {
          final customer = store.customers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CustomerCard(
              customer: customer,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CustomerOrdersScreen(customer: customer),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          customer.name.isEmpty ? '?' : customer.name[0].toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        customer.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('${customer.phone}\n${customer.orderCount} orders'),
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatCurrency(customer.totalSpent),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    ),
  );
}
