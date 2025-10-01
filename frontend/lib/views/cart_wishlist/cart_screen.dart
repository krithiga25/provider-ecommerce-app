// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/cart_wishlist/shipping_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' as rive;

class CartScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final email;

  const CartScreen({super.key, this.email});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  //late String email;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartProducts;
        return Scaffold(
          backgroundColor: Color(0xFFF7F7F7),
          bottomNavigationBar:
              cartItems.isEmpty
                  ? null
                  : BottomAppBar(
                    color: Color(0xFFF7F7F7),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ShippingAddressScreen(email: widget.email),
                          ),
                        );
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
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFFF7F7F7),
            title: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "Shopping Bag",
                  style: GoogleFonts.openSans(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          body:
              cartItems.isEmpty
                  ? Container(
                    height: MediaQuery.of(context).size.height,
                    color: Color(0xFFF7F7F7),
                    child: _emptyCart(),
                  )
                  : CustomScrollView(
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
                            height: 200,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              color: Colors.white,
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 20,
                                                      ),
                                                  child: Text(
                                                    item.title,
                                                    softWrap: true,
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.bold,
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

                                                SizedBox(height: 10),
                                                Row(
                                                  // mainAxisAlignment:
                                                  //     MainAxisAlignment
                                                  //         .spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: 35,
                                                      width: 105,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        // .redAccent
                                                        // .shade200,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.remove,
                                                              size: 15,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed:
                                                                () => cartProvider
                                                                    .decreaseQuantity(
                                                                      item.id,
                                                                      widget
                                                                          .email,
                                                                    ),
                                                          ),
                                                          Text(
                                                            '${cartProvider.getQuantity(item.id)}',
                                                            style:
                                                                GoogleFonts.openSans(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.add,
                                                              size: 15,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed:
                                                                () => cartProvider
                                                                    .increaseQuantity(
                                                                      item.id,
                                                                      widget
                                                                          .email,
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Card(
                                                      color:
                                                          Colors.grey.shade300,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2,
                                                            ),
                                                        child: Text(
                                                          "  Size:  S  ",
                                                          style:
                                                              GoogleFonts.openSans(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  // mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .delivery_dining_sharp,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(width: 3),
                                                    Expanded(
                                                      child: Text(
                                                        'Delivery by ${cartItems[index].estimatedDeliveryDate!.day.toString()} ${getMonth(cartItems[index].estimatedDeliveryDate!.month)} ${cartItems[index].estimatedDeliveryDate!.year.toString()}',
                                                        style: GoogleFonts.openSans(
                                                          fontSize: 12.5,
                                                          //fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                            _showCartDialogOptions(context, item.imageUrl, (
                                              option,
                                            ) async {
                                              if (option == 'wishlist') {
                                                final wishlistitem =
                                                    WishListItems(
                                                      id: item.id,
                                                      title: item.title,
                                                      description:
                                                          item.description,
                                                      price: item.price,
                                                      imageUrl: item.imageUrl,
                                                      rating: 3,
                                                    );
                                                final status =
                                                    await wishListProvider
                                                        .addProduct(
                                                          wishlistitem,
                                                          //"checkinglogin@gmail.com",
                                                          widget.email,
                                                        );
                                                //print(status);
                                                cartProvider.removeProduct(
                                                  item.id,
                                                  widget.email,
                                                );
                                                // Future.delayed(
                                                //   Duration(seconds: 5),
                                                //   () {
                                                //     showCustomSnackBar(
                                                //       context,
                                                //       status
                                                //           ? "Product added to wishlist!"
                                                //           : "Failed to add to wishlist",
                                                //     );
                                                //   },
                                                // );
                                              }
                                              if (option == 'delete') {
                                                final status =
                                                    await cartProvider
                                                        .removeProduct(
                                                          item.id,
                                                          widget.email,
                                                        );
                                                print(status);
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
                                              }
                                            });
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
                          height: 250,
                          // decoration: BoxDecoration(
                          //   border: Border.all(color: Colors.grey.shade300),
                          // ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\u{20B9} ${cartItems.fold(0, (a, b) => a + b.price)}',
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tax",
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\u{20B9} ${(cartItems.fold(0, (a, b) => a + b.price) * 0.18).ceilToDouble()}',
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Shipping Charges",
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Free',
                                      style: GoogleFonts.openSans(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                //Divider(thickness: 1),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "TOTAL AMOUNT",
                                      style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '\u{20B9} ${(cartItems.fold(0, (a, b) => a + b.price) * 0.018).ceilToDouble() + cartItems.fold(0, (a, b) => a + b.price)}',
                                      style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
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

  Widget _emptyCart() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: Color(0xFFF7F7F7),
          height: 500,
          child: rive.RiveAnimation.asset(
            // 'assets/empty_basket.riv',
            'assets/empty_bee.riv',
            stateMachines: [
              // 'Adding to basket - State Machine 1', //the name of the animation displayed at the top.
              'Artboard - State Machine 1',
            ], // Add the state machine name
            onInit: (rive.Artboard artboard) {
              var controller = rive.StateMachineController.fromArtboard(
                artboard,
                'State Machine 1',
              );
              if (controller != null) {
                artboard.addController(controller);
                controller.isActive = true;
              }
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Hmm.. your cart looks empty :(',
            style: GoogleFonts.openSans(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _showCartDialogOptions(
    // CartProvider cartProvider,
    // WishListProvider wishListProvider,
    BuildContext context,
    String imageUrl,
    Function(String) callback,
  ) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 420,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(image: NetworkImage(imageUrl)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Are you sure?",
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "This item made it all the way to your cart! Having second thoughts?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    color: Colors.black,
                    width: 300,
                    height: 40,
                    child: TextButton(
                      onPressed: () {
                        // setState(() {
                        //   _deleteOption = "wishlist";
                        // });
                        callback("wishlist");
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Move to Wishlist",
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // setState(() {
                      //   _deleteOption = "delete";
                      // });
                      callback("delete");
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Remove",
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 14,
                left: 14,
                child: IconButton(
                  icon: Icon(Icons.cancel),
                  color: Colors.grey.shade400,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String getMonth(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}
