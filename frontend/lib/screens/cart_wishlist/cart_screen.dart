import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/cart_wishlist/shipping_address_screen.dart';
import 'package:ecommerce_provider/screens/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _deleteOption;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.19;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartProducts;
        return cartItems.isEmpty
            ? Center(child: Text('Your cart is empty!'))
            : Scaffold(
              bottomNavigationBar: BottomAppBar(
                // color: Colors.redAccent.shade100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade100,
                    shape: RoundedRectangleBorder(),
                  ),
                  onPressed: () async {
                    // print("estimated data time");
                    // print(cartItems[0].estimatedDeliveryDate);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShippingAddressScreen(),
                      ),
                    );
                    // double totalQuantity = cartItems.fold(0, (a, b) => a + b.price);
                    // final status = await initPaymentSheet(totalQuantity);
                    // print(status);
                    // if (status == "success") {
                    //   Navigator.push(
                    //     // ignore: use_build_context_synchronously
                    //     context,
                    //     MaterialPageRoute(
                    //       builder:
                    //           (context) =>
                    //               OrderStatusSplashScreen(status: 'success'),
                    //     ),
                    //   );
                    //   Future.delayed(Duration(milliseconds: 2000), () {
                    //     Navigator.pushReplacement(
                    //       // ignore: use_build_context_synchronously
                    //       context,
                    //       MaterialPageRoute(builder: (context) => OrdersPage()),
                    //     );
                    //   });
                    // } else {
                    //   Navigator.push(
                    //     // ignore: use_build_context_synchronously
                    //     context,
                    //     MaterialPageRoute(
                    //       builder:
                    //           (context) =>
                    //               OrderStatusSplashScreen(status: 'failed'),
                    //     ),
                    //   );
                    //   Future.delayed(Duration(milliseconds: 2000), () {
                    //     Navigator.pushReplacement(
                    //       // ignore: use_build_context_synchronously
                    //       context,
                    //       MaterialPageRoute(builder: (context) => CartScreen()),
                    //     );
                    //   });
                    // }
                  },
                  //proceed for checkout.
                  child: Text(
                    "PLACE ORDER",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              //backgroundColor: Colors.white70,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "SHOPPING BAG",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              body: CustomScrollView(
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: SizedBox(
                  //     height: 50,
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 20),
                  //       child: Text(
                  //         "My cart",
                  //         style: TextStyle(color: Colors.black, fontSize: 25),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  //here:
                  SliverList(
                    delegate: SliverChildBuilderDelegate(childCount: cartItems.length, (
                      ctx,
                      index,
                    ) {
                      final item = cartItems[index];
                      //final quantity = cartProvider.getQuantity(item.id);
                      return SizedBox(
                        height: 180,
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 20,
                                              ),
                                              child: Text(
                                                item.title,
                                                softWrap: true,
                                                style: GoogleFonts.openSans(
                                                  fontWeight: FontWeight.bold,
                                                  //fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '\u{20B9} ${item.price.toStringAsFixed(2)}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              // mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.delivery_dining_sharp,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  'Delivery by ${cartItems[index].estimatedDeliveryDate!.day.toString()} March ${cartItems[index].estimatedDeliveryDate!.year.toString()}',
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 12.5,
                                                    //fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Container(
                                              height: 35,
                                              width: 105,
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.redAccent.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.remove,
                                                      size: 15,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed:
                                                        () => cartProvider
                                                            .decreaseQuantity(
                                                              item.id,
                                                            ),
                                                  ),
                                                  Text(
                                                    '${cartProvider.getQuantity(item.id)}',
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.add,
                                                      size: 15,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed:
                                                        () => cartProvider
                                                            .increaseQuantity(
                                                              item.id,
                                                            ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -5,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.grey.shade400,
                                        size: 18,
                                      ),
                                      onPressed: () async {
                                        //showProductDialog(context);
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Column(
                                              children: [
                                                Text("Product Options"),
                                                Text(
                                                  "What would you like to do?",
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    // setState(() {
                                                    //   _deleteOption = "delete";
                                                    // });
                                                    final status =
                                                        await cartProvider
                                                            .removeProduct(
                                                              item.id,
                                                            );
                                                    // Future.delayed(
                                                    //   Duration(milliseconds: 500),
                                                    //   () {
                                                    //     showCustomSnackBar(
                                                    //       context,
                                                    //       status
                                                    //           ? "Product removed from cart!"
                                                    //           : "Failed to remove from cart!",
                                                    //     );
                                                    //   },
                                                    // );
                                                  },
                                                  child: Text("Delete Product"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    final wishlistitem =
                                                        WishListItems(
                                                          id: item.id,
                                                          title: item.title,
                                                          description:
                                                              item.description,
                                                          price: item.price,
                                                          imageUrl:
                                                              item.imageUrl,
                                                          rating: 3,
                                                        );
                                                    final status =
                                                        await wishListProvider
                                                            .addProduct(
                                                              wishlistitem,
                                                              "checkinglogin@gmail.com",
                                                            );

                                                    await cartProvider
                                                        .removeProduct(item.id);
                                                    // Future.delayed(
                                                    //   Duration(milliseconds: 500),
                                                    //   () {
                                                    //     showCustomSnackBar(
                                                    //       context,
                                                    //       status
                                                    //           ? "Product moved to wishlist!"
                                                    //           : "Failed to moved to wishlist!",
                                                    //     );
                                                    //   },
                                                    // );
                                                    // setState(() {
                                                    //   _deleteOption = "wishlist";
                                                    // });
                                                  },
                                                  child: Text(
                                                    "Move to Wishlist",
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        // if (_deleteOption == 'wishlist') {
                                        //   final wishlistitem = WishListItems(
                                        //     id: item.id,
                                        //     title: item.title,
                                        //     description: item.description,
                                        //     price: item.price,
                                        //     imageUrl: item.imageUrl,
                                        //     rating: 3,
                                        //   );
                                        //   final status = await wishListProvider
                                        //       .addProduct(
                                        //         wishlistitem,
                                        //         "checkinglogin@gmail.com",
                                        //       );
                                        //   Future.delayed(
                                        //     Duration(milliseconds: 500),
                                        //     () {
                                        //       showCustomSnackBar(
                                        //         context,
                                        //         status
                                        //             ? "Product moved to wishlist!"
                                        //             : "Failed to moved to wishlist!",
                                        //       );
                                        //     },
                                        //   );
                                        //   cartProvider.removeProduct(item.id);
                                        // } else if (_deleteOption == 'delete') {
                                        //   final status = await cartProvider
                                        //       .removeProduct(item.id);
                                        //   Future.delayed(
                                        //     Duration(milliseconds: 500),
                                        //     () {
                                        //       showCustomSnackBar(
                                        //         context,
                                        //         status
                                        //             ? "Product removed from cart!"
                                        //             : "Failed to remove from cart!",
                                        //       );
                                        //     },
                                        //   );
                                        // }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "PRICE DETAILS (${cartItems.length} items)",
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: GoogleFonts.openSans(fontSize: 14),
                                ),
                                Text(
                                  '\u{20B9} ${cartItems.fold(0, (a, b) => a + b.price)}',
                                  style: GoogleFonts.openSans(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tax", style: TextStyle()),
                                Text(
                                  '\u{20B9} ${(cartItems.fold(0, (a, b) => a + b.price) * 0.018).ceilToDouble()}',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                            //Divider(thickness: 1),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "TOTAL AMOUNT",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\u{20B9} ${(cartItems.fold(0, (a, b) => a + b.price) * 0.018).ceilToDouble() + cartItems.fold(0, (a, b) => a + b.price)}',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
      },
    );
  }

  void showProductDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Text("Product Options"),
            Text("What would you like to do?"),
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
        // return AlertDialog(
        //   title: Text("Product Options"),
        //   content: Text("What would you like to do?"),
        //   actions: [

        //   ],
        // );
      },
    );
  }
}
