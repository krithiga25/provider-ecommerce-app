class Product {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final int rating;
  final String category;
  //int quantity;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.category,
    // this.quantity =1
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['productName'],
      id: json['id'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
      rating: json['rating'],
      category: json['category'],
    );
  }
}
