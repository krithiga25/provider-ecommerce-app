import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  // Sample product list
  List<Product> _products = [];

  // Getter to access products
  // i think it is required to wrap this with the consumer widget of the provider.
  List<Product> get products {
    return [..._products]; // Returns a copy to prevent direct modification
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.29.93:3000/products'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final jsonData = jsonResponse['products'];
      _products = jsonData
          .map<Product>((product) => Product.fromJson(product))
          .toList();
      // _products = jsonData
      //     .map((product) => Product.fromJson(product))
      //     .toList()
      //     .cast<Product>();
      print(_products);
      notifyListeners();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
