class CartProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;
  CartProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}
