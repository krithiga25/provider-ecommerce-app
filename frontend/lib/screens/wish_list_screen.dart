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
  void initState() {
    Provider.of<WishListProvider>(context, listen: false)
        .fetchWishlistProducts("checkinglogin@gmail.com");
    super.initState();

    // we are decoding the email id from the token we generated in the backend using the same email and secret key
    //Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    //email = decodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wish list'),
      ),
      body: Consumer<WishListProvider>(
        builder: (context, wishListProvider, child) {
          final wishListItems = wishListProvider.wishListItems;
          return wishListItems.isEmpty
              ? Center(child: Text('Your wish list is empty!'))
              : Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return ListView.builder(
                      itemCount: wishListItems.length,
                      itemBuilder: (ctx, index) {
                        final item = wishListItems[index];
                        return Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                height: 150,
                              ),
                              Column(
                                children: [
                                  Text(item.title),
                                  Text('\$${item.price.toStringAsFixed(2)}'),
                                  TextButton(
                                    child: Text("Move to cart"),
                                    onPressed: () {
                                      cartProvider.addProduct(CartProduct(
                                        id: item.id,
                                        title: item.title,
                                        description: item.description,
                                        price: item.price,
                                        imageUrl: item.imageUrl,
                                      ));
                                      wishListProvider.removeProduct(
                                          item.id, "checkinglogin@gmail.com");
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      wishListProvider.removeProduct(
                                          item.id, "checkinglogin@gmail.com");
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
      ),
    );
  }
}
