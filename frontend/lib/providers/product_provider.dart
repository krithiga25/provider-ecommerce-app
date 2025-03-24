import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_provider/screens/shared/shared.dart';
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

  //newly added products:
  List<Product> _newlyAddedProducts = [];

  List<Product> get newlyAddedProducts {
    return [..._newlyAddedProducts];
  }

  // search products:
  List<Product> _searchProducts = [];

  List<Product> get searchProducts {
    return [..._searchProducts];
  }

  // category products:
  List<Product> _categoryProducts = [];

  List<Product> get categoryProducts {
    return [..._categoryProducts];
  }

  Future<void> fetchProducts() async {
    int retries = 0;
    const int maxRetries = 4;
    const int delay = 10;
    while (retries < maxRetries) {
      try {
        print("products api hit once"); // change the delay time accordingly.
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

          //newly added products:
          _newlyAddedProducts =
              _products
                  .asMap()
                  .entries
                  .where((entry) => entry.key % 2 == 0)
                  .map((entry) => entry.value)
                  .toList();
          // _newlyAddedProducts =

          notifyListeners();
          retries = maxRetries;
          return;
        } else {
          //retries++;
          await Future.delayed(Duration(seconds: delay));
        }
      } on SocketException {
        // Handle SocketException, retry
        //retries++;
        await Future.delayed(Duration(seconds: delay));
      }
    }
    throw Exception('Failed to fetch data after $maxRetries retries');
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

      // print('in the search product function');
      // print(_searchProducts);
      notifyListeners();
    }
  }

  Future<void> categoryProduct(categoryName) async {
    final response = await http.get(Uri.parse('$url/category/$categoryName'));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      final jsonData = jsonResponse['products'];
      _categoryProducts =
          jsonData
              .map<Product>((product) => Product.fromJson(product))
              .toList();
      notifyListeners();
    }
  }
}
