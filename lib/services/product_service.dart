import 'dart:math';
import 'package:smartlocker/models/product.dart';

class ProductService {
  // Singleton pattern to ensure only one instance of the service
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<Product> _products = [
    Product(id: '1', name: 'Produk Contoh 1', price: 150000, weight: 500, stock: 10),
    Product(id: '2', name: 'Produk Contoh 2', price: 250000, weight: 750, stock: 5),
    Product(id: '3', name: 'Produk Contoh 3', price: 75000, weight: 200, stock: 20),
  ];

  List<Product> getProducts() {
    return _products;
  }

  void addProduct(Product product) {
    // Assign a unique ID
    final newProduct = Product(
      id: Random().nextInt(10000).toString(),
      name: product.name,
      price: product.price,
      weight: product.weight,
      stock: product.stock,
      imageUrl: product.imageUrl,
    );
    _products.add(newProduct);
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
  }
}