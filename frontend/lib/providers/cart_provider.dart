import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartProvider with ChangeNotifier {
  // this is private list, which can be accessed only from this class.
  List<CartProduct> _cartProducts = [];

  List<CartProduct> get cartProducts {
    return [..._cartProducts];
  }

  Future<bool> addProduct(CartProduct product, String userId) async {
    final index = _cartProducts.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _cartProducts[index].quantity++;
    } else {
      _cartProducts.add(product);
    }

    notifyListeners();
    return await addToCart(
      //"checkinglogin@gmail.com",
      userId,
      product.id,
      product.quantity,
    );
  }

  void increaseQuantity(String productId, String email) {
    final product = _cartProducts.firstWhere((item) => item.id == productId);
    product.quantity++;
    addToCart(email, product.id, product.quantity);
    notifyListeners();
  }

  void decreaseQuantity(String productId, String email) {
    final product = _cartProducts.firstWhere((item) => item.id == productId);
    if (product.quantity > 1) {
      product.quantity--;
    } else {
      removeProduct(productId, email);
    }
    removeCartProduct(email, product.id);
    notifyListeners();
  }

  Future<bool> removeProduct(String productId, String email) async {
    _cartProducts.removeWhere((item) => item.id == productId);
    notifyListeners();
    return await removeCartProduct(email, productId);
  }

  // void clearCart(email, prodId) {
  //   _cartProducts.removeWhere((item) => item.id == prodId);
  //   moveToWishlist(email, prodId);
  //   notifyListeners();
  // }

  bool isInCart(String productId) {
    return _cartProducts.any((item) => item.id == productId);
  }

  int getQuantity(String productId) {
    final product = _cartProducts.firstWhere(
      (item) => item.id == productId,
      orElse:
          () => CartProduct(
            id: '',
            title: '',
            price: 0,
            imageUrl: '',
            description: '',
            rating: 0,
            quantity: 0,
          ),
    );
    return product.quantity;
  }

  Future<void> fetchCartProducts(String user) async {
    // int retries = 0;
    // const int maxRetries = 3;
    const int delay = 500;
    while (true) {
      try {
        final response = await http.get(Uri.parse('$url/cart/$user'));
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final jsonData = jsonResponse['products'];
          _cartProducts =
              jsonData
                  .map<CartProduct>((product) => CartProduct.fromJson(product))
                  .toList();
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

  Future<bool> addToCart(user, prodId, quantity) async {
    var reqBody = {
      "userId": user,
      "products": [
        {"product": prodId, "quantity": 1},
      ],
    };
    final response = await http.post(
      Uri.parse('$url/cart'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );
    var jsonReponse = jsonDecode(response.body);
    return jsonReponse['status'];
  }

  Future<bool> removeCartProduct(user, prodId) async {
    final response = await http.delete(Uri.parse('$url/cart/$user/$prodId'));
    var jsonReponse = jsonDecode(response.body);
    return jsonReponse['status'];
  }

  Future<void> clearCart(user) async {
    await http.delete(Uri.parse('$url/clearcart/$user'));
    notifyListeners();
  }

  Future<bool> moveToWishlist(user, prodId) async {
    final response = await http.patch(Uri.parse('$url/wishlist/$user/$prodId'));
    var jsonReponse = jsonDecode(response.body);
    return jsonReponse['status'];
  }
}
