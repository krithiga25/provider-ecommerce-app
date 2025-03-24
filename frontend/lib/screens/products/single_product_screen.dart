import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class SingleProductScreen extends StatefulWidget {
  const SingleProductScreen({super.key, required this.id});
  final String id;

  @override
  State<SingleProductScreen> createState() => _SingleProductScreenState();
}

class _SingleProductScreenState extends State<SingleProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Consumer<WishListProvider>(
          builder: (context, wishListProvider, child) {
            return Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final products = productProvider.products;
                final product = products.singleWhere(
                  (id) => id.id == widget.id,
                );
                final isInCart = cartProvider.isInCart(product.id);
                final isFavorite = wishListProvider.isFavorite(product.id);
                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    title: Text(
                      'Product Details',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async {
                            if (isFavorite) {
                              final status = await wishListProvider
                                  .removeProduct(
                                    product.id,
                                    "checkinglogin@gmail.com",
                                  );
                              Future.delayed(Duration(milliseconds: 500), () {
                                showCustomSnackBar(
                                  context,
                                  status
                                      ? "Product removed from wishlist!"
                                      : "Failed to remove from wishlist!",
                                );
                              });
                            } else {
                              final wishlistProduct = WishListItems(
                                id: product.id,
                                title: product.title,
                                price: product.price,
                                imageUrl: product.imageUrl,
                                description: product.description,
                                rating: product.rating,
                              );

                              final status = await wishListProvider.addProduct(
                                wishlistProduct,
                                "checkinglogin@gmail.com",
                              );
                              Future.delayed(Duration(milliseconds: 500), () {
                                showCustomSnackBar(
                                  context,
                                  status
                                      ? "Product added to wishlist!"
                                      : "Failed to add to wishlist!",
                                );
                              });
                            }
                          },
                        ),
                        if (!isInCart)
                          Container(
                            width: 115,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 14, 64, 122),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                final cartProduct = CartProduct(
                                  id: product.id,
                                  title: product.title,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  description: product.description,
                                  rating: product.rating,
                                );

                                final status = await cartProvider.addProduct(
                                  cartProduct,
                                );
                                Future.delayed(Duration(milliseconds: 500), () {
                                  showCustomSnackBar(
                                    context,
                                    status
                                        ? "Product added to cart!"
                                        : "Failed to add to cart!",
                                  );
                                });
                              },
                              child: Text(
                                "ADD TO CART",
                                style: GoogleFonts.openSans(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 300,
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            product.title,
                            style: GoogleFonts.openSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              Text(
                                product.rating.toString(),
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                ' (${product.ratingCount.toString()} reviews)',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Spacer(),
                              Text(
                                ' \u{20B9} ${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color.fromARGB(255, 241, 164, 164),
                            ),
                            child: Text(
                              '  DESCRIPTION  ',
                              style: GoogleFonts.openSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Text(
                          //   product.description,
                          //   style: GoogleFonts.openSans(
                          //     fontSize: 15,
                          //     fontWeight: FontWeight.w600,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                          ReadMoreText(
                            product.description,
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                            trimLines: 2,
                            colorClickableText: Colors.pink,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'See more',
                            trimExpandedText: 'See less',
                            moreStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            lessStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          (product.category == 'clothes' ||
                                  product.category == 'footwear')
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 15),
                                  Text(
                                    'SELECT SIZE',
                                    style: GoogleFonts.openSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children:
                                        _sizes.map((category) {
                                          bool isSelected =
                                              _selectedSize == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 20,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedSize = category;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: _sizeTextColor,
                                                  ),
                                                  color:
                                                      isSelected
                                                          ? _sizeTextColor
                                                          : _textBgColor,
                                                ),
                                                child: Text(
                                                  category,
                                                  style: GoogleFonts.openSans(
                                                    color:
                                                        isSelected
                                                            ? _textBgColor
                                                            : _sizeTextColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              )
                              : Container(), // or SizedBox();
                          //Spacer(),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _selectedSize = '';
  final _sizeTextColor = const Color.fromARGB(255, 241, 164, 164);
  final _textBgColor = Colors.white;
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
}
