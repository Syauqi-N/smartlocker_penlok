import 'package:flutter/material.dart';
import 'package:smartlocker/services/cart_service.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final CartService _cartService = CartService();
  final PurchaseService _purchaseService = PurchaseService();
  bool _isProofUploaded = false;
  String _paymentProofImageUrl = 'assets/images/placeholder.png';

  void _uploadProof() {
    // This is a mock action. In a real app, you would use an image picker.
    setState(() {
      _isProofUploaded = true;
      // In a real app, you would get the image URL from the image picker.
      _paymentProofImageUrl = 'assets/images/placeholder.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock payment proof uploaded!')),
    );
  }

  void _confirmPurchase() {
    if (_formKey.currentState!.validate()) {
      if (!_isProofUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload payment proof first.')),
        );
        return;
      }

      for (var cartItem in _cartService.items) {
        _purchaseService.addPurchaseFromCartItem(
          cartItem: cartItem,
          buyerName: _nameController.text,
          address: _addressController.text,
          phoneNumber: _phoneController.text,
          paymentProofImageUrl: _paymentProofImageUrl,
        );
      }

      _cartService.clearCart();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Confirmed'),
          content: const Text(
              'Your order is being processed. You will be notified once the payment is verified.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Shipping Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const Divider(height: 32),
              const Text('Order Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cartService.items.length,
                itemBuilder: (context, index) {
                  final item = _cartService.items[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('${item.quantity} x IDR ${item.product.price.toStringAsFixed(0)}'),
                    trailing: Text('IDR ${(item.quantity * item.product.price).toStringAsFixed(0)}'),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Total Price',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('IDR ${_cartService.totalCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 32),
              const Text('Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(_isProofUploaded
                    ? 'Proof Uploaded'
                    : 'Upload Payment Proof'),
                onPressed: _uploadProof,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _isProofUploaded ? Colors.green : AppColors.black,
                  side: BorderSide(
                      color: _isProofUploaded ? Colors.green : AppColors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _confirmPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('CONFIRM PURCHASE',
                    style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}