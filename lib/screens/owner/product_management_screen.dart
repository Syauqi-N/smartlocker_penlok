import 'package:flutter/material.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/screens/owner/add_product_screen.dart';
import 'package:smartlocker/screens/owner/edit_product_screen.dart';
import 'package:smartlocker/services/product_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/owner_drawer.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductService _productService = ProductService();
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _products = _productService.getProducts();
    });
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _productService.deleteProduct(productId);
                  _loadProducts();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    ).then((_) => _loadProducts());
  }

  void _navigateToEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductScreen(product: product)),
    ).then((_) => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
      ),
      drawer: const OwnerDrawer(),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7, // Adjusted for buttons
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'IDR ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                      onPressed: () => _navigateToEditProduct(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
