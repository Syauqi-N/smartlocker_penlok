
class Product {
  final String id;
  String name;
  double price;
  int weight;
  int stock;
  String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.weight,
    required this.stock,
    this.imageUrl = 'assets/images/placeholder.png', // Default image
  });
}
