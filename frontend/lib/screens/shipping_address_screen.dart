import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/screens/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.19;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartProducts;
        return Scaffold(
          backgroundColor: Colors.grey.shade200,
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
              child: Text("CONTINUE"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade100,
                shape: RoundedRectangleBorder(),
              ),
              onPressed: () {
                //the payment screen
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 16,
              left: 8,
              right: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildLine(width, true),
                    SizedBox(width: 3),
                    buildStep('Cart', true),
                    SizedBox(width: 3),
                    buildLine(width, true),
                    buildStep('Address', true),
                    SizedBox(width: 3),
                    buildLine(width, false),
                    buildStep('Payment', false),
                  ],
                ),
                SizedBox(height: 50),
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User name  (default)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("1370, 2nd Main Road", style: TextStyle()),
                      Text("Mobile: 7777777777", style: TextStyle()),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  " DELIVERY ESTIMATES",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   border: Border.all(color: Colors.grey),
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: cartItems[index].imageUrl,
                                width: 70,
                                height: 70,
                              ),
                              Text(
                                'Estimated delivery by ${cartItems[index].estimatedDeliveryDate!.day.toString()} March ${cartItems[index].estimatedDeliveryDate!.year.toString()}',
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
          ),
        );
      },
    );
  }
}
