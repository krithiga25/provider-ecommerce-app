import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WishListProvider with ChangeNotifier {
  List<WishListItems> _wishListItems = [];
  List<WishListItems> get wishListItems {
    return [..._wishListItems];
  }

  // Function to add a new product
  Future<bool> addProduct(WishListItems wishListItem, String userId) async {
    _wishListItems.add(wishListItem);
    notifyListeners();
    return await addWishlist(userId, wishListItem.id);
  }

  Future<bool> removeProduct(String productId, String email) async {
    _wishListItems.removeWhere((product) => product.id == productId);

    notifyListeners();
    return await removeWishlist(email, productId);
  }

  // void clearWishList(String productId, String email) {
  //   _wishListItems.removeWhere((product) => product.id == productId);
  //   moveToCart(email, productId);
  //   notifyListeners();
  // }

  bool isFavorite(String productId) {
    return _wishListItems.any((item) => item.id == productId);
  }

  Future<bool> addWishlist(user, prodId) async {
    var reqBody = {
      "userId": user,
      "products": [prodId],
    };
    final response = await http.post(
      Uri.parse('$url/wishlist'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );
    var jsonReponse = jsonDecode(response.body);
    return jsonReponse['status'];
  }

  Future<bool> removeWishlist(user, prodId) async {
    final response = await http.delete(
      Uri.parse('$url/wishlist/$user/$prodId'),
    );
    var jsonReponse = jsonDecode(response.body);
    return jsonReponse['status'];
  }

  Future<void> fetchWishlistProducts(String user) async {
    // int retries = 0;
    // const int maxRetries = 3;
    const int delay = 500;
    while (true) {
      try {
        final response = await http.get(Uri.parse('$url/wishlist/$user'));
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final jsonData = jsonResponse['products'];
          _wishListItems =
              jsonData
                  .map<WishListItems>(
                    (product) => WishListItems.fromJson(product),
                  )
                  .toList();
          //print(_wishListItems);
          notifyListeners();
          break;
        } else {
          //retries++;
          await Future.delayed(Duration(milliseconds: delay));
        }
      } on SocketException {
        // Handle SocketException, retry
        // retries++;
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  // Future<void> moveToCart(user, prodId) async {
  //   final response = await http.patch(Uri.parse('$url/cart/$user/$prodId'));
  //   var jsonReponse = jsonDecode(response.body);
  //   if (jsonReponse['status']) {
  //     print("Moved to cart successfully");
  //   }
  // }
}
