import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
//android/app/src/main/res/values
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products]; 
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
      print(_products);
      notifyListeners();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
