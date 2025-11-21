import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleProductScreen extends StatefulWidget {
  const SingleProductScreen({
    super.key,
    required this.id,
    this.isNew = false,
    //required this.email,
  });
  final String id;
  final bool isNew;
  //final String email;
  @override
  State<SingleProductScreen> createState() => _SingleProductScreenState();
}

class _SingleProductScreenState extends State<SingleProductScreen> {
  String email = '';
  late SharedPreferences prefs;
  bool isInCart = false;
  Color _cartButtonColor = Colors.black;

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('currentuser') ?? '';
    print(email);
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
                final product = products.singleWhere(
                  (id) => id.id == widget.id,
                );
                final isFavorite = wishListProvider.isFavorite(product.id);
                return Scaffold(
                  backgroundColor: Color(0xFFF7F7F7),
                  appBar: AppBar(
                    backgroundColor: Color(0xFFF7F7F7),
                    title: Text(
                      'Product Details',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    color: Color(0xFFF7F7F7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          color: Colors.grey.shade200,
                          width: 160,
                          height: 45,
                          child: TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                  size: 25,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'wishlist',
                                  style: GoogleFonts.openSans(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              if (isFavorite) {
                                final status = await wishListProvider
                                    .removeProduct(
                                      product.id,
                                      //"checkinglogin@gmail.com",
                                      email,
                                    );
                                Future.delayed(Duration(milliseconds: 500), () {
                                  if (!context.mounted) return;
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
                                final status = await wishListProvider
                                    .addProduct(wishlistProduct, email);
                                Future.delayed(Duration(milliseconds: 500), () {
                                  if (!context.mounted) return;
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
                        ),
                        Container(
                          width: 160,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _cartButtonColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextButton(
                            onPressed:
                                !isInCart
                                    ? () async {
                                      final cartProduct = CartProduct(
                                        id: product.id,
                                        title: product.title,
                                        price: product.price,
                                        imageUrl: product.imageUrl,
                                        description: product.description,
                                        rating: product.rating,
                                      );
                                      final status = await cartProvider
                                          .addProduct(cartProduct, email);
                                      Future.delayed(
                                        Duration(milliseconds: 500),
                                        () {
                                          if (!context.mounted) return;
                                          showCustomSnackBar(
                                            context,
                                            status
                                                ? "Product added to cart!"
                                                : "Failed to add to cart!",
                                          );
                                        },
                                      );
                                      setState(() {
                                        isInCart = true;
                                        _cartButtonColor = Colors.grey.shade200;
                                      });
                                    }
                                    : () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => NavigationExample(
                                                initialIndex: 2,
                                              ),
                                        ),
                                        (route) => false,
                                      );
                                    },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: isInCart ? Colors.black : Colors.white,
                                  size: 25,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  isInCart ? "View Cart" : "Add to Cart",
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isInCart ? Colors.black : Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
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
                          Stack(
                            children: [
                              Container(
                                height: 300,
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                  ),
                                ),
                              ),
                              if (widget.isNew)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Card(
                                    color: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        "  New  ",
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
                              color: Colors.black,
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
                                              right: 16,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedSize = category;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(15),
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
                              : Container(),
                          SizedBox(height: 20),
                          Text(
                            'Reviews',
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            children:
                                _reviews.map((review) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            review.userImageUrl,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.userName,
                                              style: GoogleFonts.openSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.75,
                                              child: Text(
                                                review.reviewText,
                                                softWrap: true,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                ),
                                                Text(
                                                  review.rating.toString(),
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                          Text(
                            'Add Review',
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Share us your review..',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 5,
                                  controller: _reviewTextController,
                                ),
                                SizedBox(height: 10),
                                RatingBar(
                                  initialRating: 0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _rating = rating;
                                    });
                                  },
                                  ratingWidget: RatingWidget(
                                    full: Icon(Icons.star, color: Colors.amber),
                                    half: Icon(
                                      Icons.star,
                                      color: Colors.grey.shade400,
                                    ),
                                    empty: Icon(
                                      Icons.star,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_reviewTextController.text.isNotEmpty &&
                                        _rating != 0) {
                                      setState(() {
                                        _reviews.add(
                                          Review(
                                            id: _reviews.length + 1,
                                            userId: 1,
                                            userName: 'You',
                                            userImageUrl:
                                                'https://randomuser.me/api/portraits/men/1.jpg',
                                            reviewText:
                                                _reviewTextController.text,
                                            rating: _rating,
                                          ),
                                        );
                                        _reviewTextController.clear();
                                        _rating = 0;
                                      });
                                    }
                                  },
                                  child: Text('Post Review'),
                                ),
                              ],
                            ),
                          ),
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

  final List<Review> _reviews = [
    Review(
      id: 1,
      userId: 1,
      userName: 'Emily R.',
      userImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      reviewText:
          'I love this product! It\'s so comfortable and the quality is amazing.',
      rating: 5,
    ),
    Review(
      id: 2,
      userId: 2,
      userName: 'David K.',
      userImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      reviewText:
          'This product is okay, but it\'s not the best I\'ve ever used. The material is a bit cheap.',
      rating: 2,
    ),
    Review(
      id: 3,
      userId: 3,
      userName: 'Sophia L.',
      userImageUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
      reviewText:
          'I\'m so impressed with this product! The design is beautiful and it\'s really easy to use.',
      rating: 5,
    ),
    Review(
      id: 4,
      userId: 4,
      userName: 'Michael T.',
      userImageUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
      reviewText:
          'I\'ve been using this product for a few weeks now and I\'m really happy with it. The quality is great and it\'s really durable.',
      rating: 4,
    ),
    Review(
      id: 5,
      userId: 5,
      userName: 'Olivia W.',
      userImageUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
      reviewText:
          'I was a bit skeptical about this product at first, but it\'s really grown on me. The customer service is also really great.',
      rating: 4,
    ),
  ];

  String _selectedSize = '';
  final _sizeTextColor = Colors.black;
  final _textBgColor = Colors.white;
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final _reviewTextController = TextEditingController();
  double _rating = 0;
}

class Review {
  final int id;
  final int userId;
  final String userName;
  final String userImageUrl;
  final String reviewText;
  final double rating;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.reviewText,
    required this.rating,
  });
}
