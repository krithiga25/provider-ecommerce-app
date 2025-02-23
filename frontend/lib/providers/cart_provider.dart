import 'package:ecommerce_provider/models/cart.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  // this is private list, which can be accessed only from this class.
  final List<CartProduct> _cartProducts = [];

  List<CartProduct> get cartProducts {
    return [..._cartProducts];
  }

  // Function to add a new product
  void addProduct(CartProduct product) {
    final index = _cartProducts.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _cartProducts[index].quantity++; // Increase quantity if already in cart
    } else {
      _cartProducts.add(product); // Add new product
    }
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final product = _cartProducts.firstWhere((item) => item.id == productId);
    product.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final product = _cartProducts.firstWhere((item) => item.id == productId);
    if (product.quantity > 1) {
      product.quantity--;
    } else {
      removeProduct(productId); // Remove when quantity reaches 0
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _cartProducts.removeWhere((item) => item.id == productId);
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
}
