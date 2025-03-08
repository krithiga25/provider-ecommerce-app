import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchedProductsScreen extends StatefulWidget {
  const SearchedProductsScreen({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  State<SearchedProductsScreen> createState() => _SearchedProductsScreenState();
}

class _SearchedProductsScreenState extends State<SearchedProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        automaticallyImplyLeading: false,
        title: Text('Search for "${widget.searchQuery}"'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () {}, child: Text("Sort")),
            Container(width: 1, color: Colors.black),
            TextButton(onPressed: () {}, child: Text("Filter")),
          ],
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final productsList = productProvider.searchProducts;
          return productsList.isEmpty
              ? Center(child: Text('Can not find products for your search!'))
              : Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Consumer<WishListProvider>(
                    builder: (context, wishListProvider, child) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: 300,
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                              ),
                          itemCount: productProvider.searchProducts.length,
                          itemBuilder: (ctx, index) {
                            final item = productProvider.searchProducts[index];
                            final isFavorite = wishListProvider.isFavorite(
                              item.id,
                            );
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            child: Text("Add to cart"),
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
                                          IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  isFavorite
                                                      ? Colors.red
                                                      : null,
                                            ),
                                            onPressed: () async {
                                              if (isFavorite) {
                                                wishListProvider.removeProduct(
                                                  item.id,
                                                  "checkinglogin@gmail.com",
                                                );
                                              } else {
                                                final wishlistProduct =
                                                    WishListItems(
                                                      id: item.id,
                                                      title: item.title,
                                                      price: item.price,
                                                      imageUrl: item.imageUrl,
                                                      description:
                                                          item.description,
                                                      rating: item.rating,
                                                    );

                                                final status =
                                                    await wishListProvider
                                                        .addProduct(
                                                          wishlistProduct,
                                                          "checkinglogin@gmail.com",
                                                        );
                                                showCustomSnackBar(
                                                  context,
                                                  status
                                                      ? "Product added to wishlist!"
                                                      : "Failed to add to wishlist!",
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
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
              );
        },
      ),
    );
  }
}
