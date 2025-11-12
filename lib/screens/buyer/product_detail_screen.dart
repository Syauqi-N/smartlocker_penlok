import 'package:flutter/material.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/screens/buyer/checkout_screen.dart';
import 'package:smartlocker/services/cart_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: _ProductImage(imageUrl: product.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'IDR ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (product.storeName.isNotEmpty) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.store, color: AppColors.grey),
                      title: Text(product.storeName),
                      subtitle: Text(
                        product.storeLocation?.isNotEmpty == true
                            ? product.storeLocation!
                            : 'Seller: ${product.storeOwnerName.isNotEmpty ? product.storeOwnerName : 'SmartLocker Seller'}',
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Chip(
                        backgroundColor: AppColors.primary.withAlpha(77),
                        label: Text('Stock: ${product.stock}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'No description available.'
                        : product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                CartService().addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added to cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('ADD TO CART',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                CartService().addToCart(product);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('BUY NOW',
                  style: TextStyle(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.png',
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/placeholder.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
