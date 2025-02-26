import 'dart:convert';

import 'package:ecommerce_provider/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartProvider with ChangeNotifier {
  // this is private list, which can be accessed only from this class.
  List<CartProduct> _cartProducts = [];

  List<CartProduct> get cartProducts {
    return [..._cartProducts];
  }

  void addProduct(CartProduct product) {
    final index = _cartProducts.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _cartProducts[index].quantity++;
    } else {
      _cartProducts.add(product);
    }
    addToCart("checkinglogin@gmail.com", product.id, product.quantity);
    notifyListeners();
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
      orElse: () => CartProduct(
          id: '',
          title: '',
          price: 0,
          //imageUrl: '',
          description: '',
          quantity: 0),
    );
    return product.quantity;
  }

  Future<void> addToCart(user, prodId, quantity) async {
    var reqBody = {
      "userId": user,
      "products": [
        {"product": prodId, "quantity": 1}
      ]
    };
    final response = await http.post(
        Uri.parse('http://192.168.29.93:3000/cart'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("add successfully");
    }
  }

  Future<void> fetchCartProducts(String user) async {
    final response = await http.get(
      Uri.parse('http://192.168.29.93:3000/cart/$user'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final jsonData =
          jsonResponse['products']; // this itself contains the quantity
      print(jsonResponse['quantity']); //null
      print(jsonData);
      _cartProducts = jsonData
          .map<CartProduct>((product) => CartProduct.fromJson(product))
          .toList();
      print(_cartProducts);
      notifyListeners();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> removeCartProduct(user, prodId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.29.93:3000/cart/$user/$prodId'),
    );
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("deleted successfully");
    }
  }

  Future<void> moveToWishlist(user, prodId) async {
    final response = await http.patch(
      Uri.parse('http://192.168.29.93:3000/wishlist/$user/$prodId'),
    );
    var jsonReponse = jsonDecode(response.body);
    if (jsonReponse['status']) {
      print("Moved to wishlist successfully");
    }
  }
}
