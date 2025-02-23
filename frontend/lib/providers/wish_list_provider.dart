import 'dart:convert';

import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Here, you are creating a new instance of CartProvider manually instead of using the one provided by Provider.
//CartProvider cartProvider = CartProvider();

class WishListProvider with ChangeNotifier {
  List<WishListItems> _wishListItems = [];
  List<WishListItems> get wishListItems {
    return [..._wishListItems];
  }

  // Function to add a new product
  void addProduct(WishListItems wishListItem, String userId) {
    _wishListItems.add(wishListItem);
    // call the api to add the product on wishlist schema
    addWishlist(userId, wishListItem.id);
    notifyListeners();
  }

  void removeProduct(String productId, String email) {
    _wishListItems.removeWhere((product) => product.id == productId);
    // call the api to add the product on wishlist schema
    removeWishlist(email, productId);
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _wishListItems.any((item) => item.id == productId);
  }

  Future<void> addWishlist(user, prodId) async {
    var reqBody = {
      "userId": user,
      "products": [prodId]
    };
    final response = await http.post(
        Uri.parse('http://192.168.29.93:3000/wishlist'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("add successfully");
    }
  }

  Future<void> removeWishlist(user, prodId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.29.93:3000/wishlist/$user/$prodId'),
    );
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("deleted successfully");
    }
  }

  Future<void> fetchWishlistProducts(String user) async {
    final response = await http.get(
      Uri.parse('http://192.168.29.93:3000/wishlist/$user'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final jsonData = jsonResponse['products'];
      _wishListItems = jsonData
          .map<WishListItems>((product) => WishListItems.fromJson(product))
          .toList();
      // _products = jsonData
      //     .map((product) => Product.fromJson(product))
      //     .toList()
      //     .cast<Product>();
      print(_wishListItems);
      notifyListeners();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
