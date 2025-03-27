import 'dart:math';

Random random = Random();

class Product {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final int rating;
  final String category;
  int ratingCount;
  bool isNew;

  Product(
    int ratingCount, {
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.category,
    this.isNew = false,
  }) : ratingCount = Random().nextInt(1000) + 1;

  factory Product.fromJson(Map<String, dynamic> json) {
    String id = json['id'];
    int index = int.parse(id.substring(3));
    bool isNew = index % 2 != 0;
    return Product(
      0,
      title: json['productName'],
      id: json['id'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
      rating: json['rating'],
      category: json['category'],
      isNew: isNew,
    );
  }

  factory Product.popularProduct(Map<String, dynamic> json) {
    return Product(
      0,
      title: json['productName'],
      id: json['id'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
      rating: json['rating'],
      category: json['category'],
    );
  }

  factory Product.searchProduct(Map<String, dynamic> json) {
    final product = json['product'];
    return Product(
      0,
      title: product['productName'],
      id: product['id'],
      description: product['description'],
      price: product['price'],
      imageUrl: product['image'],
      rating: product['rating'],
      category: product['category'],
    );
  }
}
