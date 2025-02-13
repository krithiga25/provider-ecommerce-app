import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:flutter/material.dart';

//Here, you are creating a new instance of CartProvider manually instead of using the one provided by Provider.
//CartProvider cartProvider = CartProvider();

class WishListProvider with ChangeNotifier {
  final List<WishListItems> _wishListItems = [];
  List<WishListItems> get wishListItems {
    return [..._wishListItems];
  }

  // Function to add a new product
  void addProduct(WishListItems wishListItem) {
    _wishListItems.add(wishListItem);
    notifyListeners();
  }

  void removeProduct(String productId) {
    _wishListItems.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _wishListItems.any((item) => item.id == productId);
  }
}
