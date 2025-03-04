import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:flutter/material.dart';
//import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductsScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
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
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    Provider.of<WishListProvider>(context, listen: false)
        .fetchWishlistProducts("checkinglogin@gmail.com");
    Provider.of<CartProvider>(context, listen: false)
        .fetchCartProducts("checkinglogin@gmail.com");
    // we are decoding the email id from the token we generated in the backend using the same email and secret key
    //Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    //email = decodedToken['email'];
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
                  title: Center(child: Text("Home")),
                ),
                body: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, index) {
                    final product = products[index];
                    final isFavorite = wishListProvider.isFavorite(product.id);
                    final isInCart = cartProvider.isInCart(product.id);
                    final quantity = cartProvider.getQuantity(product.id);
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            //width: double.infinity,
                            height: 200,
                          ),
                          Column(
                            children: [
                              //Text(product.title),
                              //('\$${product.price.toStringAsFixed(2)}'),
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
                                    wishListProvider.removeProduct(
                                        product.id, "checkinglogin@gmail.com");
                                  } else {
                                    final wishListProduct = WishListItems(
                                      id: product.id,
                                      title: product.title,
                                      price: product.price,
                                      imageUrl: "",
                                      description: product.description,
                                    );
                                    wishListProvider.addProduct(wishListProduct,
                                        "checkinglogin@gmail.com");
                                  }
                                },
                              ),
                            ],
                          )
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
