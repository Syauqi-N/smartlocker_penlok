import 'package:flutter/material.dart';
import 'package:smartlocker/widgets/owner_drawer.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
      ),
      drawer: const OwnerDrawer(),
      body: ListView.builder(
        itemCount: 15, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text('#${index + 1}')),
              title: const Text('Product Name Sold'),
              subtitle: const Text('Buyer: John Doe'),
              trailing: const Text('28 Aug 2025'),
            ),
          );
        },
      ),
    );
  }
}
