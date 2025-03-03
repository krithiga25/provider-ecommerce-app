class WishListItems {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;

  WishListItems({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
    factory WishListItems.fromJson(Map<String, dynamic> json) {
    return WishListItems(
      title: json['productName'],
      id: json['id'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
    );
  }
}
