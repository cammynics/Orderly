import 'package:flutter/material.dart';

import '../utils/theme.dart';
import 'customers_screen.dart';
import 'order_form_screen.dart';
import 'orders_screen.dart';
import 'summary_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Orders', 'Sales summary', 'Customers'];
  static const _pages = [OrdersScreen(), SummaryScreen(), CustomersScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 68,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: OrderlyTheme.primaryGradient),
      ),
      title: Text(_titles[_index]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: OrderlyTheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: OrderlyTheme.primaryDark,
            ),
          ),
        ),
      ],
    ),
    body: IndexedStack(index: _index, children: _pages),
    floatingActionButton: _index == 0
        ? FloatingActionButton(
            tooltip: 'Add order',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const OrderFormScreen()),
            ),
            child: const Icon(Icons.add),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.query_stats_outlined),
          selectedIcon: Icon(Icons.query_stats),
          label: 'Summary',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Customers',
        ),
      ],
    ),
  );
}
