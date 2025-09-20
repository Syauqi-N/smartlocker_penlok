import 'package:flutter/material.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/owner_drawer.dart';

class OwnerNotificationsScreen extends StatelessWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Notifications'),
      ),
      drawer: const OwnerDrawer(),
      body: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.shopping_cart_checkout, color: AppColors.secondary),
              title: const Text('New Order Received!'),
              subtitle: const Text('John Doe purchased "Product Name"'),
              trailing: Text('${index * 5 + 2} mins ago'),
            ),
          );
        },
      ),
    );
  }
}
