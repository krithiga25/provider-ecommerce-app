import 'package:cached_network_image/cached_network_image.dart';
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
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartProducts;
        return Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "My cart",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: cartItems.length,
                  (ctx, index) {
                    final item = cartItems[index];
                    final quantity = cartProvider.getQuantity(item.id);
                    return cartItems.isEmpty
                        ? Center(child: Text('Your cart is empty!'))
                        : Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          color: Colors.white,
                          child: Consumer<WishListProvider>(
                            builder: (context, wishListProvider, child) {
                              return Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: item.imageUrl,
                                          fit: BoxFit.cover,
                                          height: 140,
                                        ),
                                      ),
                                      //SizedBox(width: 20),
                                      SizedBox(
                                        width: 200,
                                        //color: Colors.yellow,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.start,
                                          children: [
                                            Text(item.title, softWrap: true),
                                            Text(
                                              '\$${item.price.toStringAsFixed(2)}',
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove),
                                                  onPressed: () {
                                                    cartProvider
                                                        .decreaseQuantity(
                                                          item.id,
                                                        );
                                                  },
                                                ),
                                                Text('$quantity'),
                                                IconButton(
                                                  icon: Icon(Icons.add),
                                                  onPressed: () {
                                                    cartProvider
                                                        .increaseQuantity(
                                                          item.id,
                                                        );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.cancel_presentation,
                                        color: Colors.grey.shade800,
                                      ),
                                      onPressed: () {
                                        showProductDialog(context);
                                        if (_deleteOption == 'wishlist') {
                                          wishListProvider.addProduct(
                                            WishListItems(
                                              id: item.id,
                                              title: item.title,
                                              description: item.description,
                                              price: item.price,
                                              imageUrl: item.imageUrl,
                                              rating: 3,
                                            ),
                                            "checkinglogin@gmail.com",
                                          );
                                        }
                                        cartProvider.removeProduct(item.id);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text("PRICE DETAILS (${cartItems.length} items)"),
                      Divider(thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: TextStyle()),
                          Text(
                            '${cartItems.fold(0, (a, b) => a + b.price)}',
                            style: TextStyle(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tax", style: TextStyle()),
                          Text('45', style: TextStyle()),
                        ],
                      ),
                      Divider(thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text('500', style: TextStyle()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade100,
                      shape: RoundedRectangleBorder(
                        //borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      double totalQuantity = cartItems.fold(
                        0,
                        (a, b) => a + b.price,
                      );
                      final status = await initPaymentSheet(totalQuantity);
                      print(status);
                      if (status == "success") {
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    OrderStatusSplashScreen(status: 'success'),
                          ),
                        );
                        Future.delayed(Duration(milliseconds: 2000), () {
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersPage(),
                            ),
                          );
                        });
                      } else {
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    OrderStatusSplashScreen(status: 'failed'),
                          ),
                        );
                        Future.delayed(Duration(milliseconds: 2000), () {
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(),
                            ),
                          );
                        });
                      }
                    },
                    //proceed for checkout.
                    child: Text(
                      "Procced to place order",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              // SliverPersistentHeader(delegate: ),
            ],
          ),
        );
      },
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
