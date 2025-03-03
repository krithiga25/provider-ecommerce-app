class CartProduct {
  final String id;
  final String title;
  final String description;
  final int price;
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

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final quantity = json['quantity'];

    return CartProduct(
      title: product['productName'],
      id: product['id'],
      description: product['description'],
      price: product['price'],
      imageUrl: product['image'],
      quantity: quantity,
    );
  }
}
