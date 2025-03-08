import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchedProductsScreen extends StatefulWidget {
  const SearchedProductsScreen({super.key});

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
        title: Text('Searched products'),
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
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 300,
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (ctx, index) {
                          final item = productProvider.products[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.fitWidth,
                                  width: 180,
                                  height: 150,
                                ),
                                Column(
                                  children: [
                                    Text(item.title),
                                    Text('\$${item.price.toStringAsFixed(2)}'),
                                    TextButton(
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
                                    IconButton(
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
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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
