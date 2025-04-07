import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    // Provider.of<OrdersProvider>(
    //   context,
    //   listen: false,
    // ).fetchOrders("krithiperu2002@gmail.com");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(backgroundColor: Color(0xFFF7F7F7), title: Text("Orders")),
      body: Center(child: Text("Orders Page")),
    );
  }
}
