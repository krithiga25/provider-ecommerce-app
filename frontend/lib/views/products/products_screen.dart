import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/products/categories_products_screen.dart';
import 'package:ecommerce_provider/views/products/searched_products_screen.dart';
import 'package:ecommerce_provider/views/products/single_product_screen.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_provider/views/login_register/profile.dart';
//import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' as rive;
import '../../providers/product_provider.dart';

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
    // Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    // email = decodedToken['email'];
    email = 'krithiperu';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Consumer<WishListProvider>(
          builder: (context, wishListProvider, child) {
            return Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final products = productProvider.newlyAddedProducts;
                return Scaffold(
                  //backgroundColor: Color(0xFFFFFFFF),
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Center(
                      child: Text(
                        "Home",
                        style: GoogleFonts.openSans(
                          //color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileScreen(email: 'email'),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: Image(
                              image: AssetImage('assets/fox_profile.jpg'),
                              width: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  body:
                      productProvider.products.isEmpty
                          ? Center(child: loadingAnimation())
                          :
                          // Center(
                          //   child: CircularProgressIndicator(
                          //     color: Colors.blueGrey,
                          //   ),
                          // ):
                          CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: _searchWidget(productProvider, context),
                              ),
                              SliverToBoxAdapter(
                                child: _categoryWidget(context),
                              ),
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _popularProduct(
                                      productProvider,
                                      wishListProvider,
                                      cartProvider,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 22),
                                      child: Text(
                                        'Newly Added',
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  ctx,
                                  index,
                                ) {
                                  final product = products[index];
                                  final isFavorite = wishListProvider
                                      .isFavorite(product.id);
                                  final isInCart = cartProvider.isInCart(
                                    product.id,
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: SizedBox(
                                      height: 220,
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          SingleProductScreen(
                                                            id: product.id,
                                                            isNew:
                                                                product.isNew,
                                                          ),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          // left: 20,
                                                          right: 5,
                                                          top: 10,
                                                          bottom: 10,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          product.imageUrl,
                                                      fit: BoxFit.cover,
                                                      height: 140,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    // color: Colors.blue,
                                                    width: 180,
                                                    child: Stack(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          // mainAxisAlignment:
                                                          //     MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 8,
                                                                    bottom: 4,
                                                                  ),
                                                              child: Text(
                                                                product.title,
                                                                style: GoogleFonts.openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              maxLines: 2,
                                                              product
                                                                  .description,
                                                              softWrap: true,
                                                              //overflow: TextOverflow.ellipsis,
                                                              style:
                                                                  GoogleFonts.openSans(),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Row(
                                                              children: [
                                                                Row(
                                                                  children: List.generate(
                                                                    5,
                                                                    (
                                                                      index,
                                                                    ) => Icon(
                                                                      index <
                                                                              product.rating
                                                                          ? Icons
                                                                              .star
                                                                          : Icons
                                                                              .star_border,
                                                                      color:
                                                                          index <
                                                                                  product.rating
                                                                              ? Colors.yellow
                                                                              : Colors.grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '(${product.ratingCount.toString()})',
                                                                  style:
                                                                      GoogleFonts.openSans(),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              ' \u{20B9} ${product.price.toStringAsFixed(2)}',
                                                              style: GoogleFonts.openSans(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (!isInCart)
                                                          Positioned(
                                                            bottom: 20,
                                                            left: 0,
                                                            child: Container(
                                                              width: 115,
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    const Color.fromARGB(
                                                                      255,
                                                                      14,
                                                                      64,
                                                                      122,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                              ),
                                                              child: TextButton(
                                                                // style: ElevatedButton.styleFrom(
                                                                //   backgroundColor:
                                                                //       Colors
                                                                //           .redAccent
                                                                //           .shade200,
                                                                //   shape: RoundedRectangleBorder(
                                                                //     borderRadius:
                                                                //         BorderRadius.circular(
                                                                //           10,
                                                                //         ),
                                                                //   ),
                                                                // ),
                                                                onPressed: () async {
                                                                  final cartProduct = CartProduct(
                                                                    id:
                                                                        product
                                                                            .id,
                                                                    title:
                                                                        product
                                                                            .title,
                                                                    price:
                                                                        product
                                                                            .price,
                                                                    imageUrl:
                                                                        product
                                                                            .imageUrl,
                                                                    description:
                                                                        product
                                                                            .description,
                                                                    rating:
                                                                        product
                                                                            .rating,
                                                                  );

                                                                  final status =
                                                                      await cartProvider
                                                                          .addProduct(
                                                                            cartProduct,
                                                                          );
                                                                  Future.delayed(
                                                                    Duration(
                                                                      milliseconds:
                                                                          500,
                                                                    ),
                                                                    () {
                                                                      showCustomSnackBar(
                                                                        context,
                                                                        status
                                                                            ? "Product added to cart!"
                                                                            : "Failed to add to cart!",
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child: Text(
                                                                  "ADD TO CART",
                                                                  style: GoogleFonts.openSans(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (isInCart)
                                                          Positioned(
                                                            bottom: 20,
                                                            left: 0,
                                                            child: Container(
                                                              height: 35,
                                                              width: 115,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    const Color.fromARGB(
                                                                      255,
                                                                      14,
                                                                      64,
                                                                      122,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size: 15,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    onPressed:
                                                                        () => cartProvider.decreaseQuantity(
                                                                          product
                                                                              .id,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    '${cartProvider.getQuantity(product.id)}',
                                                                    style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      Icons.add,
                                                                      size: 15,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    onPressed:
                                                                        () => cartProvider.increaseQuantity(
                                                                          product
                                                                              .id,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        Positioned(
                                                          top: 0,
                                                          right: -15,
                                                          child: IconButton(
                                                            icon: Icon(
                                                              isFavorite
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color:
                                                                  isFavorite
                                                                      ? Colors
                                                                          .red
                                                                      : null,
                                                            ),
                                                            onPressed: () async {
                                                              if (isFavorite) {
                                                                final status = await wishListProvider
                                                                    .removeProduct(
                                                                      product
                                                                          .id,
                                                                      "checkinglogin@gmail.com",
                                                                    );
                                                                Future.delayed(
                                                                  Duration(
                                                                    milliseconds:
                                                                        500,
                                                                  ),
                                                                  () {
                                                                    showCustomSnackBar(
                                                                      context,
                                                                      status
                                                                          ? "Product removed from wishlist!"
                                                                          : "Failed to remove from wishlist!",
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                final wishlistProduct = WishListItems(
                                                                  id:
                                                                      product
                                                                          .id,
                                                                  title:
                                                                      product
                                                                          .title,
                                                                  price:
                                                                      product
                                                                          .price,
                                                                  imageUrl:
                                                                      product
                                                                          .imageUrl,
                                                                  description:
                                                                      product
                                                                          .description,
                                                                  rating:
                                                                      product
                                                                          .rating,
                                                                );

                                                                final status = await wishListProvider
                                                                    .addProduct(
                                                                      wishlistProduct,
                                                                      "checkinglogin@gmail.com",
                                                                    );
                                                                Future.delayed(
                                                                  Duration(
                                                                    milliseconds:
                                                                        500,
                                                                  ),
                                                                  () {
                                                                    showCustomSnackBar(
                                                                      context,
                                                                      status
                                                                          ? "Product added to wishlist!"
                                                                          : "Failed to add to wishlist!",
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 10,
                                            child: Card(
                                              color: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
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
                                    ),
                                  );
                                }, childCount: products.length),
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
  }

  Widget _popularProduct(
    ProductProvider prodProvider,
    WishListProvider wishListProvider,
    CartProvider cartProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Poupular products',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    prodProvider.popularProducts.map((product) {
                      final isFavorite = wishListProvider.isFavorite(
                        product.id,
                      );
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      SingleProductScreen(id: product.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: CachedNetworkImage(
                                          // 'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-images/electronics/headphones.jpg',
                                          // 'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-pdf-bucket//jacket2.jpg',
                                          //'assets/iphone.jpg',
                                          imageUrl: product.imageUrl,
                                          fit: BoxFit.fitWidth,
                                          height: 120,
                                          // width:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.3,
                                          //width: 150,
                                        ),
                                      ),
                                      Text(
                                        product.title,
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => Icon(
                                                index < product.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color:
                                                    index < product.rating
                                                        ? Colors.yellow
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '(${product.ratingCount.toString()})',
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '\u{20B9} ${product.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : null,
                                    ),
                                    onPressed: () async {
                                      if (isFavorite) {
                                        final status = await wishListProvider
                                            .removeProduct(
                                              product.id,
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
                                            .addProduct(
                                              wishlistProduct,
                                              "checkinglogin@gmail.com",
                                            );
                                        Future.delayed(
                                          Duration(milliseconds: 500),
                                          () {
                                            showCustomSnackBar(
                                              context,
                                              status
                                                  ? "Product added to wishlist!"
                                                  : "Failed to add to wishlist!",
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchWidget(ProductProvider productProvider, BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for a product',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter something for search';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      showCustomSnackBar(context, 'Enter something for search');
                    });
                    showCustomSnackBar(context, 'Enter something for search');
                    return;
                  }
                  // here added await, cause in the search page, page is built before the response is recieved and the page is empty.
                  productProvider.searchProduct(controller.text);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => SearchedProductsScreen(
                            searchQuery: controller.text,
                          ),
                    ),
                  );
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<CategoriesList> _categoriesList = [
    CategoriesList(
      categoryName: 'clothes',
      categoryImageUrl:
          'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-images/category/clothes_category.jpg',
    ),
    CategoriesList(
      categoryName: 'accessories',
      categoryImageUrl:
          'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-images/category/accessories_category.jpg',
    ),
    CategoriesList(
      categoryName: 'electronics',
      categoryImageUrl:
          'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-images/category/electronics_category.jpg',
    ),
    CategoriesList(
      categoryName: 'footwear',
      categoryImageUrl:
          "https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-images/category/shoe_category.jpg",
    ),
  ];

  Widget _categoryWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _categoriesList.map((category) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => CategoryProductsScreen(
                                    categoryName: category.categoryName,
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            //top: 10,
                            //bottom: 10,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: category.categoryImageUrl,
                            fit: BoxFit.cover,
                            height: 110,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget loadingAnimation() {
  return Column(
    children: [
      SizedBox(
        height: 400,
        child: rive.RiveAnimation.asset(
          'assets/earth_loading.riv',
          stateMachines: [
            'Loading Final - State Machine 1', //the name of the animation displayed at the top.
          ], // Add the state machine name
          onInit: (rive.Artboard artboard) {
            var controller = rive.StateMachineController.fromArtboard(
              artboard,
              'State Machine 1',
            );
            if (controller != null) {
              artboard.addController(controller);
              controller.isActive = true;
            }
          },
        ),
      ),
      Text(
        'Hold on, loading products for you...',
        style: GoogleFonts.openSans(
          fontSize: 18,
          color: Colors.blueGrey,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class CategoriesList {
  final String categoryName;
  final String categoryImageUrl;

  CategoriesList({required this.categoryName, required this.categoryImageUrl});
}
