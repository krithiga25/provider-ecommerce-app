import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  // Sample product list
  final List<Product> _products = [
    Product(
      id: 'p1',
      title: 'Laptop',
      description: 'A high-performance laptop for professionals.',
      price: 999.99,
      imageUrl: 'https://unsplash.com/photos/shallow-focus-photography-of-books-lUaaKCUANVI',
    ),
    Product(
      id: 'p2',
      title: 'Smartphone',
      description: 'Latest smartphone with amazing features.',
      price: 799.99,
      imageUrl: 'https://unsplash.com/photos/shallow-focus-photography-of-books-lUaaKCUANVI',
    ),
  ];

  // Getter to access products
  // i think it is required to wrap this with the consumer widget of the provider. 
  List<Product> get products {
    return [..._products]; // Returns a copy to prevent direct modification
  }

  // Function to add a new product
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners(); // Notify listeners about the change
  }

  void removeProduct(Product product) {
    _products.remove(product);
    notifyListeners(); // Notify listeners about the change
  }
}
