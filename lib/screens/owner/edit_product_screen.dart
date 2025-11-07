import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/services/product_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key, required this.product});

  final Product product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  String? _imagePath;
  bool _removeImage = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _stockController =
        TextEditingController(text: widget.product.stock.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _productService.updateProduct(
        id: widget.product.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        description: _descriptionController.text.trim(),
        imagePath: _imagePath,
        removeImage: _removeImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _imagePath = picked.path;
      _removeImage = false;
    });
  }

  void _clearImage() {
    setState(() {
      _imagePath = null;
      _removeImage = widget.product.imageUrl != null &&
          widget.product.imageUrl!.isNotEmpty;
    });
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
              const Text('Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _EditableImageSelector(
                imagePath: _imagePath,
                existingImageUrl: widget.product.imageUrl,
                isRemoved: _removeImage,
                onPick: _isSaving ? null : _pickImage,
                onClear: (_imagePath != null ||
                        (widget.product.imageUrl != null &&
                            widget.product.imageUrl!.isNotEmpty))
                    ? _clearImage
                    : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: _validateRequired,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _stockController,
                label: 'Stock',
                keyboardType: TextInputType.number,
                validator: _validateInteger,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: _validateRequired,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAVE CHANGES',
                        style: TextStyle(color: AppColors.black)),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number.';
    }
    return null;
  }

  String? _validateInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer.';
    }
    return null;
  }
}

class _EditableImageSelector extends StatelessWidget {
  const _EditableImageSelector({
    required this.imagePath,
    required this.existingImageUrl,
    required this.isRemoved,
    this.onPick,
    this.onClear,
  });

  final String? imagePath;
  final String? existingImageUrl;
  final bool isRemoved;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey),
                ),
                child: _buildImage(),
              ),
            ),
            if (onClear != null &&
                (imagePath != null ||
                    (existingImageUrl != null &&
                        existingImageUrl!.isNotEmpty &&
                        !isRemoved)))
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath != null) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
      );
    }
    if (isRemoved || existingImageUrl == null || existingImageUrl!.isEmpty) {
      return const Icon(Icons.add_a_photo, color: AppColors.grey, size: 32);
    }
    return Image.network(
      existingImageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: AppColors.grey, size: 32),
    );
  }
}
