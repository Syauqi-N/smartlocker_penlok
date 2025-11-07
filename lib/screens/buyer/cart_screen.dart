import 'package:flutter/material.dart';

import 'package:smartlocker/screens/buyer/checkout_screen.dart';
import 'package:smartlocker/services/cart_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  void _updateCart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      drawer: const BuyerDrawer(),
      body: ListView.builder(
        itemCount: _cartService.items.length,
        itemBuilder: (context, index) {
          final cartItem = _cartService.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _CartProductImage(imageUrl: cartItem.product.imageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IDR ${cartItem.product.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (cartItem.quantity > 1) {
                            cartItem.quantity--;
                          } else {
                            _cartService.removeFromCart(cartItem);
                          }
                          _updateCart();
                        },
                      ),
                      Text(cartItem.quantity.toString(),
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          cartItem.quantity++;
                          _updateCart();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Price:',
                  style: TextStyle(color: AppColors.grey)),
              Text(
                'IDR ${_cartService.totalCost.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            child: const Text('CHECKOUT',
                style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

class _CartProductImage extends StatelessWidget {
  const _CartProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const placeholder = 'assets/images/placeholder.png';
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        placeholder,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imageUrl!,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        placeholder,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }
}
