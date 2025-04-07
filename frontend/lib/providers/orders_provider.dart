import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_provider/models/orders.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersProvider with ChangeNotifier {
  List<OrderDetails> _orders = [];

  List<OrderDetails> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders(String user) async {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$url/orders/$user'));
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final jsonData = jsonResponse['orders'];
          _orders =
              jsonData
                  .map<OrderDetails>((order) => OrderDetails.fromJson(order))
                  .toList();
          notifyListeners();
          print(_orders.last.products.first.product);
          break;
        } else {
          //retries++;
          await Future.delayed(Duration(milliseconds: 500));
        }
      } on SocketException {
        // Handle SocketException, retry
        // retries++;
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }
}
