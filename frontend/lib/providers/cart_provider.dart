import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/screens/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartProvider with ChangeNotifier {
  // this is private list, which can be accessed only from this class.
  List<CartProduct> _cartProducts = [];

  List<CartProduct> get cartProducts {
    return [..._cartProducts];
  }

  Future<bool> addProduct(CartProduct product) async {
    final index = _cartProducts.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _cartProducts[index].quantity++;
    } else {
      _cartProducts.add(product);
    }

    notifyListeners();
    return await addToCart(
      "checkinglogin@gmail.com",
      product.id,
      product.quantity,
    );
  }

  void increaseQuantity(String productId) {
    final product = _cartProducts.firstWhere((item) => item.id == productId);
    product.quantity++;
    addToCart("checkinglogin@gmail.com", product.id, product.quantity);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final product = _cartProducts.firstWhere((item) => item.id == productId);
    if (product.quantity > 1) {
      product.quantity--;
    } else {
      removeProduct(productId);
    }
    removeCartProduct("checkinglogin@gmail.com", product.id);
    notifyListeners();
  }

  void removeProduct(String productId) {
    _cartProducts.removeWhere((item) => item.id == productId);
    removeCartProduct("checkinglogin@gmail.com", productId);
    notifyListeners();
  }

  void clearCart(email, prodId) {
    //clearing the cart
    _cartProducts.removeWhere((item) => item.id == prodId);
    //moving the wishlist, updated in db, but not reflected in the ui - since we are not creating the product object here.
    moveToWishlist(email, prodId);
    notifyListeners();
  }

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

  Future<void> fetchCartProducts(String user) async {
    // int retries = 0;
    // const int maxRetries = 3;
    const int delay = 500;
    while (true) {
      try {
        final response = await http.get(Uri.parse('$url/cart/$user'));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          print(jsonResponse);
          final jsonData =
              jsonResponse['products']; // this itself contains the quantity
          print(jsonResponse['quantity']); //null
          print(jsonData);
          _cartProducts =
              jsonData
                  .map<CartProduct>((product) => CartProduct.fromJson(product))
                  .toList();
          print(_cartProducts);
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

  Future<void> removeCartProduct(user, prodId) async {
    final response = await http.delete(Uri.parse('$url/cart/$user/$prodId'));
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("deleted successfully");
    }
  }

  Future<void> moveToWishlist(user, prodId) async {
    final response = await http.patch(Uri.parse('$url/wishlist/$user/$prodId'));
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("Moved to wishlist successfully");
    }
  }
}
