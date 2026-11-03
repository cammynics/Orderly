import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/order_store.dart';
import '../utils/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_card.dart';
import 'order_form_screen.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  OrderStatus? _status;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim().toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) => Consumer<OrderStore>(
    builder: (context, store, _) {
      if (store.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      final matches = store.orders
          .where((order) {
            final matchesStatus = _status == null || order.status == _status;
            final matchesQuery =
                _query.isEmpty ||
                order.customerName.toLowerCase().contains(_query) ||
                order.orderNumber.toLowerCase().contains(_query) ||
                order.productName.toLowerCase().contains(_query);
            return matchesStatus && matchesQuery;
          })
          .toList(growable: false);

      return RefreshIndicator(
        onRefresh: store.load,
        color: OrderlyTheme.primaryDark,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search orders or customers',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildFilters(context, store.orders)),
            if (store.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    store.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            if (matches.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: store.orders.isEmpty
                      ? 'Your orders start here'
                      : 'No results found',
                  message: store.orders.isEmpty
                      ? 'Keep every customer order in one calm, clear place.'
                      : 'Try another name, product, order number, or status.',
                  actionLabel: store.orders.isEmpty
                      ? 'Add your first order'
                      : null,
                  onAction: store.orders.isEmpty
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const OrderFormScreen(),
                          ),
                        )
                      : null,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final order = matches[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(order.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(context, order),
                        onDismissed: (_) async {
                          await store.delete(order);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${order.orderNumber} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => store.restore(order),
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: OrderlyTheme.cancelled,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: OrderlyTheme.surface,
                          ),
                        ),
                        child: OrderCard(
                          order: order,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OrderDetailsScreen(order: order),
                            ),
                          ),
                          onStatusChanged: (status) =>
                              store.updateStatus(order, status),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _buildFilters(BuildContext context, List<Order> orders) {
    final counts = <OrderStatus, int>{
      for (final status in OrderStatus.values)
        status: orders.where((order) => order.status == status).length,
    };
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(context, 'All', null, orders.length),
          for (final status in OrderStatus.values)
            _filterChip(context, status.label, status, counts[status]!),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    OrderStatus? value,
    int count,
  ) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text('$label $count'),
      selected: _status == value,
      onSelected: (_) => setState(() => _status = value),
      selectedColor: OrderlyTheme.highlight,
      side: BorderSide(
        color: _status == value ? OrderlyTheme.primary : OrderlyTheme.border,
      ),
      labelStyle: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: OrderlyTheme.text, fontWeight: FontWeight.w600),
      showCheckmark: false,
    ),
  );

  Future<bool> _confirmDelete(BuildContext context, Order order) async =>
      await showDialog<bool>(
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
      ) ??
      false;
}
