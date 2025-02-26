import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/cart_screen.dart';
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            icon: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Consumer<WishListProvider>(
        builder: (context, wishListProvider, child) {
          final wishListItems = wishListProvider.wishListItems;
          return wishListItems.isEmpty
              ? Center(child: Text('Your wish list is empty!'))
              : ListView.builder(
                  itemCount: wishListItems.length,
                  itemBuilder: (ctx, index) {
                    final item = wishListItems[index];
                    return ListTile(
                        leading: Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            // this "add" button simply adds quantity in the cart page.
                            return TextButton(
                              child: Text("Move to cart"),
                              onPressed: () {
                                cartProvider.addProduct(CartProduct(
                                  id: item.id,
                                  title: item.title,
                                  description: item.description,
                                  price: item.price,
                                  //imageUrl: item.imageUrl,
                                ));
                                // wishListProvider.clearWishList(
                                //     item.id, "checkinglogin@gmail.com");
                                wishListProvider.removeProduct(
                                    item.id, "checkinglogin@gmail.com");
                              },
                            );
                          },
                        ),
                        title: Text(item.title),
                        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            wishListProvider.removeProduct(
                                item.id, "checkinglogin@gmail.com");
                          },
                        ));
                  },
                );
        },
      ),
    );
  }
}
