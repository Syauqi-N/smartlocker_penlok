import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/services/product_service.dart';
import 'package:smartlocker/services/transaction_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageInputScreen extends StatefulWidget {
  final Package? package;

  const PackageInputScreen({super.key, this.package});

  @override
  State<PackageInputScreen> createState() => _PackageInputScreenState();
}

class _PackageInputScreenState extends State<PackageInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  List<Product> _products = const [];
  Product? _selectedProduct;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialiseForm();
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _shippingAddressController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _initialiseForm() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await _productService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _selectedProduct = products.isNotEmpty ? products.first : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    try {
      await _transactionService.createTransaction(
        productId: _selectedProduct!.id,
        quantity: quantity,
        buyerFullName: _receiverNameController.text.trim(),
        shippingAddress: _shippingAddressController.text.trim(),
        buyerPhoneNumber: _receiverPhoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package created successfully.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create package: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Package'),
      ),
      drawer: const ReceiverDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        DropdownButtonFormField<Product>(
                          initialValue: _selectedProduct,
                          items: _products
                              .map(
                                (product) => DropdownMenuItem<Product>(
                                  value: product,
                                  child: Text(product.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedProduct = value),
                          decoration: const InputDecoration(
                            labelText: 'Product',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null ? 'Select a product' : null,
                        ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter quantity';
                              }
                              final parsed = int.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return 'Quantity must be greater than zero';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _receiverNameController,
                            decoration: const InputDecoration(
                              labelText: 'Receiver Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter receiver name'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _receiverPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Receiver Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter receiver phone number'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _shippingAddressController,
                            decoration: const InputDecoration(
                              labelText: 'Delivery Address',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter delivery address'
                                    : null,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: const Text(
                              'Create Package',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
