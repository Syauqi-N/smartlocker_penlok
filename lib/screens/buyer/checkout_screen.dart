import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartlocker/models/transaction.dart';
import 'package:smartlocker/services/cart_service.dart';
import 'package:smartlocker/services/transaction_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/app_logo.dart';

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
  final TransactionService _transactionService = TransactionService();
  final ImagePicker _picker = ImagePicker();

  TransactionModel? _transaction;
  bool _initializing = false;
  bool _isUploading = false;
  bool _isSubmitting = false;
  String? _initializationError;
  XFile? _selectedImage;
  Duration? _expiresIn;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    _initializeTransaction();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeTransaction() async {
    if (_cartService.items.isEmpty) {
      setState(() {
        _initializationError = 'Your cart is empty.';
      });
      return;
    }

    if (_cartService.items.length > 1) {
      setState(() {
        _initializationError =
            'Multiple product checkout is not supported yet. Please checkout items one at a time.';
      });
      return;
    }

    setState(() {
      _initializing = true;
      _initializationError = null;
    });

    final cartItem = _cartService.items.first;
    final productId = cartItem.product.id;

    try {
      final transaction = await _transactionService.createTransaction(
        productId: productId,
        quantity: cartItem.quantity,
        buyerFullName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        shippingAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        buyerPhoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _transaction = transaction;
        _initializing = false;
      });
      _startExpiryCountdown(transaction.paymentExpiresAt);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initializationError = error.toString();
      });
    }
  }

  void _startExpiryCountdown(DateTime? expiresAt) {
    _expiryTimer?.cancel();
    if (expiresAt == null) {
      setState(() {
        _expiresIn = null;
      });
      return;
    }

    void updateTimer() {
      final remaining = expiresAt.difference(DateTime.now());
      if (!mounted) {
        _expiryTimer?.cancel();
        return;
      }
      setState(() {
        _expiresIn = remaining.isNegative ? Duration.zero : remaining;
      });
      if (remaining.isNegative) {
        _expiryTimer?.cancel();
      }
    }

    updateTimer();
    _expiryTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => updateTimer());
  }

  Future<void> _pickAndUploadProof() async {
    if (_transaction == null || _isUploading) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _selectedImage = picked;
      _isUploading = true;
    });

    try {
      final updated = await _transactionService.uploadPaymentProof(
        transactionId: _transaction!.id,
        imagePath: picked.path,
      );
      if (!mounted) return;
      setState(() {
        _transaction = updated;
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof uploaded successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _confirmPurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_transaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Transaction not ready. Please try again.')),
      );
      return;
    }

    if (!_transaction!.hasPaymentProof) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload payment proof before confirming.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updated = await _transactionService.updateBuyerShipping(
        id: _transaction!.id,
        buyerFullName: _nameController.text.trim(),
        shippingAddress: _addressController.text.trim(),
        buyerPhoneNumber: _phoneController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _transaction = updated;
        _isSubmitting = false;
      });

      _cartService.clearCart();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Confirmed'),
          content: const Text(
            'Your order is being processed. You will be notified once the payment is verified.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours}h ' : ''}$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            AppTextLogo(height: 28),
            SizedBox(width: 8),
            Text('Checkout'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Shipping Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (cartItems.isEmpty)
                const Text(
                  'Your cart is currently empty.',
                  style: TextStyle(color: AppColors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                          '${item.quantity} x IDR ${item.product.price.toStringAsFixed(0)}'),
                      trailing: Text(
                          'IDR ${(item.quantity * item.product.price).toStringAsFixed(0)}'),
                    );
                  },
                ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Total Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'IDR ${_cartService.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 32),
              const Text(
                'Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_initializing)
                const Center(child: CircularProgressIndicator())
              else if (_initializationError != null)
                Text(
                  _initializationError!,
                  style: const TextStyle(color: Colors.red),
                )
              else if (_transaction == null)
                const Text(
                  'Unable to prepare the transaction.',
                  style: TextStyle(color: Colors.red),
                )
              else ...[
                _buildQrisSection(_transaction!),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(
                    _transaction!.hasPaymentProof
                        ? 'Payment Proof Uploaded'
                        : 'Upload Payment Proof',
                  ),
                  onPressed: _isUploading ? null : _pickAndUploadProof,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _transaction!.hasPaymentProof
                        ? Colors.green
                        : AppColors.black,
                    side: BorderSide(
                      color: _transaction!.hasPaymentProof
                          ? Colors.green
                          : AppColors.grey,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (_transaction!.hasPaymentProof ||
                    _selectedImage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Uploaded Proof',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _transaction!.paymentProof != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _transaction!.paymentProof!,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                ],
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: !_isSubmitting &&
                        _transaction != null &&
                        _transaction!.hasPaymentProof
                    ? _confirmPurchase
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'CONFIRM PURCHASE',
                        style: TextStyle(color: AppColors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrisSection(TransactionModel transaction) {
    const assetPath = 'assets/images/qris.png';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              assetPath,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Text(
                    'QR image not found.\nPlease add assets/images/qris.png',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (transaction.paymentUrl != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _openPaymentUrl(transaction.paymentUrl!),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open payment link'),
          ),
        ],
        if (_expiresIn != null) ...[
          const SizedBox(height: 8),
          Text(
            _expiresIn == Duration.zero
                ? 'QRIS has expired. Please recreate the transaction.'
                : 'QR expires in ${_formatDuration(_expiresIn!)}',
            style: TextStyle(
              color: _expiresIn == Duration.zero ? Colors.red : AppColors.grey,
            ),
          ),
        ],
      ],
    );
  }

  void _openPaymentUrl(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open this link in your browser: $url')),
    );
  }
}
