import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/cart_screen.dart';
import 'package:ecommerce_provider/screens/wish_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductsScreen extends StatefulWidget {
  final token;
  const ProductsScreen({super.key, this.token});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String email;

  @override
  void initState() {
    super.initState();
    // we are decoding the email id from the token we generated in the backend using the same email and secret key
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    email = decodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Consumer<WishListProvider>(
            builder: (context, wishListProvider, child) {
          return Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final products = productProvider.products;
              return Scaffold(
                appBar: AppBar(
                  title: Text(email),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => CartScreen()),
                        );
                      },
                      icon: Icon(Icons.shopping_cart),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => WishListScreen()),
                        );
                      },
                      icon: Icon(Icons.favorite),
                    ),
                  ],
                ),
                body: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, index) {
                    final product = products[index];
                    final isFavorite = wishListProvider.isFavorite(product.id);
                    final isInCart = cartProvider.isInCart(product.id);
                    final quantity = cartProvider.getQuantity(product.id);
                    return Card(
                      child: Column(
                        children: [
                          Text(product.title),
                          Text('\$${product.price.toStringAsFixed(2)}'),
                          // this should have add to cart intially
                          // after variable check: it should display this "add" button and a delete button to delete - remove from cart.
                          // add button should increase the quantity, not add the same the product again.

                          //if the product's quantity is 0, it will show "add to cart", else it will show the following widget:
                          // contains quantity, add button, remove button.
                          // add button increases the count of the product.
                          // remove button - removes the product from the cart list - then shows the "add to cart" button.

                          // If NOT in cart, show "Add to Cart" button
                          if (!isInCart)
                            TextButton(
                              child: Text("Add to Cart"),
                              onPressed: () {
                                final cartProduct = CartProduct(
                                  id: product.id,
                                  title: product.title,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  description: product.description,
                                );
                                cartProvider.addProduct(cartProduct);
                              },
                            ),
                          if (isInCart)
                            Row(children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  cartProvider.decreaseQuantity(product.id);
                                },
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  cartProvider.increaseQuantity(product.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cartProvider.removeProduct(product.id);
                                },
                              ),
                            ]),
                          // here the product should have each heart which upon selected will be added to the wishlist
                          // and later that we can un-wishlist it.
                          // upon adding it again and again, the product is getting added like a new object.
                          // so i think it should have a toggle option to achieve this.
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              if (isFavorite) {
                                wishListProvider.removeProduct(product.id);
                              } else {
                                final wishListProduct = WishListItems(
                                  id: product.id,
                                  title: product.title,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  description: product.description,
                                );
                                wishListProvider.addProduct(wishListProduct);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        });
      },
    );
  }
}
