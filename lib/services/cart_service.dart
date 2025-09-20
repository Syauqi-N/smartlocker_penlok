import 'package:smartlocker/models/cart_item.dart';
import 'package:smartlocker/models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product product) {
    // Check if the product is already in the cart
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity++;
        return;
      }
    }
    // If not, add it as a new item
    _items.add(CartItem(product: product));
  }

  void removeFromCart(CartItem cartItem) {
    _items.remove(cartItem);
  }

  void clearCart() {
    _items.clear();
  }

  double get totalCost {
    double total = 0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }
}