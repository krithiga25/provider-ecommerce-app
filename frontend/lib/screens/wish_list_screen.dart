import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:flutter/material.dart';
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
                    padding: const EdgeInsets.only(top: 20.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent: 300,
                        crossAxisCount: 2, // number of columns
                        childAspectRatio: 1, // aspect ratio of each child
                      ),
                      itemCount: wishListProvider.wishListItems.length,
                      itemBuilder: (ctx, index) {
                        final item = wishListProvider.wishListItems[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.fitWidth,
                                      width: 140,
                                      height: 180,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(item.title),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.purpleAccent.shade100,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        child: Text("Move to cart"),
                                        onPressed: () {
                                          cartProvider.addProduct(
                                            CartProduct(
                                              id: item.id,
                                              title: item.title,
                                              description: item.description,
                                              price: item.price,
                                              imageUrl: item.imageUrl,
                                              rating: item.rating,
                                            ),
                                          );
                                          wishListProvider.removeProduct(
                                            item.id,
                                            "checkinglogin@gmail.com",
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: -5,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.cancel_presentation_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    wishListProvider.removeProduct(
                                      item.id,
                                      "checkinglogin@gmail.com",
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
