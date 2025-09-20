import 'package:flutter/material.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/services/product_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _weightController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _weightController = TextEditingController(text: widget.product.weight.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        weight: int.tryParse(_weightController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        imageUrl: widget.product.imageUrl, // Keep original image for now
      );

      _productService.updateProduct(updatedProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo section could be improved to allow changing photos
              const Text('Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.asset(widget.product.imageUrl, height: 150, fit: BoxFit.cover),
              const SizedBox(height: 24),
              _buildTextField(controller: _nameController, label: 'Product Name', validator: _validateRequired),
              const SizedBox(height: 16),
              _buildTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number, validator: _validateNumber),
              const SizedBox(height: 16),
              _buildTextField(controller: _weightController, label: 'Weight (grams)', keyboardType: TextInputType.number, validator: _validateNumber),
              const SizedBox(height: 16),
              _buildTextField(controller: _stockController, label: 'Stock', keyboardType: TextInputType.number, validator: _validateNumber),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(color: AppColors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number.';
    }
    return null;
  }
}