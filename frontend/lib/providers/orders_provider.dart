import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ecommerce_provider/models/orders.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersProvider with ChangeNotifier {
  List<OrderDetails> _orders = [];

  List<OrderDetails> get orders {
    return [..._orders.reversed];
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
          //print(_orders.last.products.first.product);
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

  String generateOrderId() {
    var rng = Random();
    var randomDigits = rng.nextInt(1000000).toString().padLeft(6, '0');
    return 'ORDID$randomDigits';
  }

  Future<bool> createOrder({
    required String user,
    required final products,
    required int subTotal,
    required int tax,
    required int total,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    var reqBody = {
      "email": user,
      "orderId": generateOrderId(),
      "products":
          products.map((item) {
            return {
              "product": item.id,
              "quantity": item.quantity,
              "price": item.price,
            };
          }).toList(),
      "subtotal": subTotal,
      "tax": tax,
      "total": total,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      //need to change it as processing
      "orderStatus": "pending",
      "shippingAddress": {
        "name": "John Doe",
        "address": "123 Main St",
        "city": "Anytown",
        "state": "CA",
        "zip": "12345",
        "country": "USA",
      },
    };
    final response = await http.post(
      Uri.parse('$url/createorder'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );
    var jsonReponse = jsonDecode(response.body);
    print(jsonReponse['error']);
    return jsonReponse['status'];
  }

  //update the delivery status.
}
