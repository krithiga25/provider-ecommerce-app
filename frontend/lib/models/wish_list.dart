import 'dart:math';

class WishListItems {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final int rating;
  int ratingCount;

  WishListItems({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
  }) : ratingCount = Random().nextInt(1000) + 1;

  factory WishListItems.fromJson(Map<String, dynamic> json) {
    return WishListItems(
      title: json['productName'],
      id: json['id'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
      rating: json['rating'],
    );
  }
}
