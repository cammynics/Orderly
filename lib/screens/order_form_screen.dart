import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../providers/order_store.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';
import '../widgets/gradient_button.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({this.order, super.key});

  final Order? order;

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  late DateTime _orderDate;
  late OrderStatus _status;
  double _total = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _customerName = order?.customerName ?? '';
    _orderDate = order?.orderDate ?? DateTime.now();
    _status = order?.status ?? OrderStatus.pending;
    if (order != null) {
      _phoneController.text = order.customerPhone;
      _addressController.text = order.customerAddress;
      _productController.text = order.productName;
      _quantityController.text = '${order.quantity}';
      _priceController.text = '${order.unitPrice}';
      _notesController.text = order.notes;
      _total = order.total;
    }
    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _productController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    setState(() => _total = quantity * price);
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<OrderStore>().customers;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'New order' : 'Edit order'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _sectionTitle(context, 'Customer'),
              const SizedBox(height: 12),
              Autocomplete<Customer>(
                initialValue: TextEditingValue(
                  text: widget.order?.customerName ?? '',
                ),
                displayStringForOption: (customer) => customer.name,
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return const Iterable<Customer>.empty();
                  return customers.where(
                    (customer) =>
                        customer.name.toLowerCase().contains(query) ||
                        customer.phone.toLowerCase().contains(query),
                  );
                },
                onSelected: (customer) {
                  _customerName = customer.name;
                  _phoneController.text = customer.phone;
                  _addressController.text = customer.address;
                },
                fieldViewBuilder: (context, controller, focusNode, _) =>
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (value) => _customerName = value,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Customer name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          AppValidators.requiredText(value, 'Customer name'),
                    ),
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 220,
                        maxWidth: 360,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final customer = options.elementAt(index);
                          return ListTile(
                            title: Text(customer.name),
                            subtitle: Text(customer.phone),
                            onTap: () => onSelected(customer),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+() -]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Contact number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: AppValidators.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Order details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) =>
                    AppValidators.requiredText(value, 'Product name'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: AppValidators.positiveInteger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Unit price',
                      ),
                      validator: AppValidators.nonNegativePrice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _totalPanel(context),
              const SizedBox(height: 24),
              _sectionTitle(context, 'When and status'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Order date  ·  ${formatDate(_orderDate)}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OrderStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.track_changes_outlined),
                ),
                items: OrderStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Notes'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: _isSaving ? 'Saving...' : 'Save order',
                icon: Icons.check,
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w700),
  );

  Widget _totalPanel(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: OrderlyTheme.totalGradient,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(Icons.calculate_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Order total',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Text(
          formatCurrency(_total),
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _orderDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final store = context.read<OrderStore>();
    final draft = store.createDraft(
      customerName: _customerName,
      customerPhone: _phoneController.text,
      customerAddress: _addressController.text,
      productName: _productController.text,
      quantity: int.parse(_quantityController.text),
      unitPrice: double.parse(_priceController.text),
      orderDate: _orderDate,
      status: _status,
      notes: _notesController.text,
      existing: widget.order,
    );
    final saved = await store.save(draft: draft);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(store.errorMessage ?? 'Unable to save this order.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${saved.orderNumber} saved')));
    Navigator.of(context).pop();
  }
}
