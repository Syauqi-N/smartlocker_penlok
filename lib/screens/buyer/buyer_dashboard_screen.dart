import 'package:flutter/material.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/screens/buyer/product_detail_screen.dart';
import 'package:smartlocker/services/product_service.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';
import 'package:smartlocker/widgets/product_card.dart';

class BuyerDashboardScreen extends StatelessWidget {
  const BuyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> products = ProductService().getProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      drawer: const BuyerDrawer(),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}