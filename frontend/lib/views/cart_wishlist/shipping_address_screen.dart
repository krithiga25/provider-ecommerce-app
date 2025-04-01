import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/payment.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/views/cart_wishlist/cart_screen.dart';
import 'package:ecommerce_provider/views/orders_payment/orders_screen.dart';
import 'package:ecommerce_provider/views/orders_payment/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width * 0.19;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartProducts;
        return Scaffold(
          // backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            title: Text(
              "ADDRESS",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(),
              ),
              onPressed: () async {
                //the payment screen
                double totalQuantity = cartItems.fold(0, (a, b) => a + b.price);
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
                      MaterialPageRoute(builder: (context) => OrdersPage()),
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
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  });
                }
              },
              child: Text(
                "CONTINUE",
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          body:
          // cartItems.isEmpty?
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        bottom: 10,
                        top: 10,
                      ),
                      child: Text(
                        "DEFAULT",
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 50),
                      child: Container(
                        //height: 200,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        padding: const EdgeInsets.only(
                          left: 16,
                          bottom: 60,
                          top: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Krithiga Perumal",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "1370, 2nd Main Road\nVelachery, Chennai.",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Mobile: 9876543210",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 15),
                      child: Text(
                        " DELIVERY ESTIMATES",
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: cartItems.length,
                  (ctx, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.5,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              imageUrl: cartItems[index].imageUrl,
                              width: 70,
                              height: 70,
                            ),
                            Text(
                              'Estimated delivery by ${cartItems[index].estimatedDeliveryDate!.day.toString()} ${getMonth(cartItems[index].estimatedDeliveryDate!.month)} ${cartItems[index].estimatedDeliveryDate!.year.toString()}',
                              style: GoogleFonts.openSans(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // : Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     // Row(
          //     //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     //   children: [
          //     //     buildLine(width, true),
          //     //     SizedBox(width: 3),
          //     //     buildStep('Cart', true),
          //     //     SizedBox(width: 3),
          //     //     buildLine(width, true),
          //     //     buildStep('Address', true),
          //     //     SizedBox(width: 3),
          //     //     buildLine(width, false),
          //     //     buildStep('Payment', false),
          //     //   ],
          //     // ),
          //     SizedBox(height: 50),
          //     Container(
          //       height: 200,
          //       width: MediaQuery.of(context).size.width,
          //       color: Colors.white,
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             "User name  (default)",
          //             style: TextStyle(fontWeight: FontWeight.bold),
          //           ),
          //           Text("1370, 2nd Main Road", style: TextStyle()),
          //           Text("Mobile: 7777777777", style: TextStyle()),
          //         ],
          //       ),
          //     ),
          //     SizedBox(height: 50),
          //     Text(
          //       " DELIVERY ESTIMATES",
          //       style: TextStyle(fontWeight: FontWeight.w600),
          //     ),
          //     SizedBox(height: 10),
          //     Container(
          //       height: 200,
          //       width: MediaQuery.of(context).size.width,
          //       color: Colors.white,
          //       // decoration: BoxDecoration(
          //       //   color: Colors.white,
          //       //   border: Border.all(color: Colors.grey),
          //       //   borderRadius: BorderRadius.circular(10),
          //       // ),
          //       child: ListView.builder(
          //         itemCount: cartItems.length,
          //         itemBuilder: (context, index) {
          //           return Container(
          //             decoration: BoxDecoration(
          //               border: Border(
          //                 bottom: BorderSide(
          //                   color: Colors.grey.shade200,
          //                 ),
          //               ),
          //             ),
          //             child: ListTile(
          //               title: Row(
          //                 mainAxisAlignment: MainAxisAlignment.start,
          //                 children: [
          //                   CachedNetworkImage(
          //                     imageUrl: cartItems[index].imageUrl,
          //                     width: 70,
          //                     height: 70,
          //                   ),
          //                   Text(
          //                     'Estimated delivery by ${cartItems[index].estimatedDeliveryDate!.day.toString()} March ${cartItems[index].estimatedDeliveryDate!.year.toString()}',
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        );
      },
    );
  }
}
