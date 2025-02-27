import 'package:ecommerce_provider/models/payment.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/orders_screen.dart';
import 'package:ecommerce_provider/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _deleteOption;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart screen')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartProducts;
          return cartItems.isEmpty
              ? Center(child: Text('Your cart is empty!'))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, index) {
                    final item = cartItems[index];
                    final quantity = cartProvider.getQuantity(item.id);
                    return Card(child: Consumer<WishListProvider>(
                        builder: (context, wishListProvider, child) {
                      return Column(
                        children: [
                          Text(item.title),
                          Text('\$${item.price.toStringAsFixed(2)}'),
                          Row(children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.decreaseQuantity(item.id);
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                cartProvider.increaseQuantity(item.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showProductDialog(context);
                                if (_deleteOption == 'wishlist') {
                                  wishListProvider.addProduct(
                                      WishListItems(
                                        id: item.id,
                                        title: item.title,
                                        description: item.description,
                                        price: item.price,
                                        //imageUrl: item.imageUrl,
                                      ),
                                      "checkinglogin@gmail.com");
                                }
                                cartProvider.removeProduct(item.id);
                              },
                            ),
                          ]),
                          //this will lead to the order page consisting of all the order items and then a payment method?
                          // for now => the list of cart items will be put in the orders page as in Map Data strcuture, with oder id as the key.
                          TextButton(
                              onPressed: () async {
                                int totalQuantity =
                                    cartItems.fold(0, (a, b) => a + b.price);
                                final status =
                                    await initPaymentSheet(totalQuantity);
                                if (status == "success") {
                                  Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderStatusSplashScreen(
                                                status: 'success')),
                                  );
                                  Future.delayed(Duration(milliseconds: 2000),
                                      () {
                                    Navigator.pushReplacement(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OrdersPage()),
                                    );
                                  });
                                } else {
                                  Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderStatusSplashScreen(
                                                status: 'failed')),
                                  );
                                  Future.delayed(Duration(milliseconds: 2000),
                                      () {
                                    Navigator.pushReplacement(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CartScreen()),
                                    );
                                  });
                                }
                              },
                              child: Text("Procced to place order")),
                        ],
                      );
                    }));
                  },
                );
        },
      ),
    );
  }

  void showProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Product Options"),
          content: Text("What would you like to do?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _deleteOption = "delete";
                });
              },
              child: Text("Delete Product"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _deleteOption = "wishlist";
                });
                Navigator.pop(context);
              },
              child: Text("Move to Wishlist"),
            ),
          ],
        );
      },
    );
  }
}
