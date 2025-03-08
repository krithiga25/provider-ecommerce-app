import 'dart:convert';

import 'package:ecommerce_provider/screens/shared.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;

//android/app/src/main/res/values
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  //popular products:
  List<Product> _populuarProducts = [];

  List<Product> get popularProducts {
    return [..._populuarProducts];
  }

  // search products:
  List<Product> _searchProducts = [];

  List<Product> get searchProducts {
    return [..._searchProducts];
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('$url/products'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final jsonData = jsonResponse['products'];
      _products.clear();
      _products =
          jsonData
              .map<Product>((product) => Product.fromJson(product))
              .toList();
      //popular products:
      final selectiveProducts =
          jsonData
              .where((product) => jsonData.indexOf(product) % 2 != 0)
              .toList();
      _populuarProducts =
          selectiveProducts
              .map<Product>((product) => Product.popularProduct(product))
              .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> searchProduct(searchQuery) async {
    final response = await http.get(Uri.parse('$url/search/$searchQuery'));
    var jsonResponse = jsonDecode(response.body);
    // need to give status in the backend.
    if (jsonResponse['searchResults'] != null) {
      final jsonData = jsonResponse['searchResults'];
      _searchProducts.clear();
      _searchProducts =
          jsonData
              .map<Product>((product) => Product.searchProduct(product))
              .toList();
      notifyListeners();
    }
  }
}
