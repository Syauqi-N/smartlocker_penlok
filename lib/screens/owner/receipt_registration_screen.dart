import 'package:flutter/material.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/owner_drawer.dart';

class ReceiptRegistrationScreen extends StatelessWidget {
  const ReceiptRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Registration'),
      ),
      drawer: const OwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Register a New Receipt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Receipt Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Simulate save
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt Saved!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('SAVE RECEIPT', style: TextStyle(color: AppColors.black)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
