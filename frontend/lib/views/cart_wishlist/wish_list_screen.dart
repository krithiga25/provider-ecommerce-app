import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16),
          child: Center(child: Text('My wish list')),
        ),
      ),
      body: Consumer<WishListProvider>(
        builder: (context, wishListProvider, child) {
          final wishListItems = wishListProvider.wishListItems;
          return wishListItems.isEmpty
              ? Center(child: Text('Your wish list is empty!'))
              : Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 5,
                      right: 5,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent: 340,
                        crossAxisCount: 2, // number of columns
                        childAspectRatio: 1, // aspect ratio of each child
                      ),
                      itemCount: wishListProvider.wishListItems.length,
                      itemBuilder: (ctx, index) {
                        final item = wishListProvider.wishListItems[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 25,
                                          left: 25,
                                          bottom: 25,
                                          top: 25,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: item.imageUrl,
                                          fit: BoxFit.fitWidth,
                                          width: 140,
                                          height: 180,
                                        ),
                                      ),
                                      Positioned(
                                        left: 16,
                                        bottom: -11,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Card(
                                            color: Colors.white70,
                                            //elevation: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 3),
                                                  Text(
                                                    item.rating.toString(),
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    height: 16,
                                                    width: 1,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(width: 15),
                                                  Text(
                                                    item.ratingCount.toString(),
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      top: 5,
                                    ),
                                    child: Text(
                                      item.title,
                                      style: GoogleFonts.openSans(),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      '\u{20B9} ${item.price.toStringAsFixed(2)}',
                                      style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Divider(height: 1),
                                  TextButton(
                                    // style: ElevatedButton.styleFrom(
                                    //   // backgroundColor:
                                    //   //     Colors.purpleAccent.shade100,
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(
                                    //       5,
                                    //     ),
                                    //   ),
                                    // ),
                                    child: Center(
                                      child: Text(
                                        "MOVE TO CART",
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent.shade200,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final cartProduct = CartProduct(
                                        id: item.id,
                                        title: item.title,
                                        price: item.price,
                                        imageUrl: item.imageUrl,
                                        description: item.description,
                                        rating: item.rating,
                                      );

                                      final status = await cartProvider
                                          .addProduct(cartProduct);
                                      Future.delayed(
                                        Duration(milliseconds: 500),
                                        () {
                                          showCustomSnackBar(
                                            context,
                                            status
                                                ? "Product added to cart!"
                                                : "Failed to add to cart!",
                                          );
                                        },
                                      );
                                      wishListProvider.removeProduct(
                                        "checkinglogin@gmail.com",
                                        item.id,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: -5,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () async {
                                    final status = await wishListProvider
                                        .removeProduct(
                                          item.id,
                                          "checkinglogin@gmail.com",
                                        );
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        showCustomSnackBar(
                                          context,
                                          status
                                              ? "Product removed from wishlist!"
                                              : "Failed to remove from wishlist!",
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
        },
      ),
    );
  }
}
