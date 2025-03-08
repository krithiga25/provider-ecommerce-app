import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/searched_products_screen.dart';
import 'package:ecommerce_provider/screens/shared.dart';
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
                    actions: [
                      //CircleAvatar()  //later update it with the user profile pic
                      IconButton(
                        onPressed: () {
                          //user data page -> with an arrow icon to return to the home page.
                        },
                        icon: Icon(Icons.person),
                      ),
                    ],
                    title: Center(child: Text("Home")),
                  ),
                  body: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _searchWidget(productProvider, context),
                      ),
                      SliverPersistentHeader(delegate: _CategoryHeader()),
                      SliverToBoxAdapter(
                        child: _popularProduct(
                          productProvider,
                          wishListProvider,
                          cartProvider,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((ctx, index) {
                          final product = products[index];
                          final isFavorite = wishListProvider.isFavorite(
                            product.id,
                          );
                          final isInCart = cartProvider.isInCart(product.id);
                          final quantity = cartProvider.getQuantity(product.id);
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    fit: BoxFit.cover,
                                    height: 200,
                                  ),
                                  Column(
                                    children: [
                                      Text(product.title),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          product.description,
                                          softWrap: true,
                                        ),
                                      ),
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
                                        '${product.price.toStringAsFixed(2)} rs',
                                      ),
                                      Row(
                                        children: [
                                          if (!isInCart)
                                            TextButton(
                                              child: Text("Add to Cart"),
                                              onPressed: () {
                                                final cartProduct = CartProduct(
                                                  id: product.id,
                                                  title: product.title,
                                                  price: product.price,
                                                  imageUrl: product.imageUrl,
                                                  description:
                                                      product.description,
                                                  rating: product.rating,
                                                );
                                                cartProvider.addProduct(cartProduct).then((
                                                  status,
                                                ) {
                                                  if (status) {
                                                    showCustomSnackBar(
                                                      // ignore: use_build_context_synchronously
                                                      context,
                                                      "Product added to cart!",
                                                    );
                                                  } else {
                                                    showCustomSnackBar(
                                                      // ignore: use_build_context_synchronously
                                                      context,
                                                      "Failed to add to cart!",
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                          if (isInCart)
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove),
                                                  onPressed: () {
                                                    cartProvider
                                                        .decreaseQuantity(
                                                          product.id,
                                                        );
                                                  },
                                                ),
                                                Text('$quantity'),
                                                IconButton(
                                                  icon: Icon(Icons.add),
                                                  onPressed: () {
                                                    cartProvider
                                                        .increaseQuantity(
                                                          product.id,
                                                        );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    cartProvider.removeProduct(
                                                      product.id,
                                                    );
                                                  },
                                                ),
                                              ],
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
                                            onPressed: () {
                                              if (isFavorite) {
                                                wishListProvider.removeProduct(
                                                  product.id,
                                                  "checkinglogin@gmail.com",
                                                );
                                              } else {
                                                wishListProvider
                                                    .addProduct(
                                                      WishListItems(
                                                        id: product.id,
                                                        title: product.title,
                                                        price: product.price,
                                                        imageUrl:
                                                            product.imageUrl,
                                                        description:
                                                            product.description,
                                                        rating: product.rating,
                                                      ),
                                                      "checkinglogin@gmail.com",
                                                    )
                                                    .then((status) {
                                                      if (status) {
                                                        ScaffoldMessenger.of(
                                                          // ignore: use_build_context_synchronously
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Product added to wishlist',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
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
      //color: const Color.fromARGB(255, 215, 246, 202),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Poupular products', style: TextStyle(fontSize: 18)),
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    prodProvider.popularProducts.map((product) {
                      final isFavorite = wishListProvider.isFavorite(
                        product.id,
                      );
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Card(
                          color: const Color.fromARGB(255, 195, 197, 194),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    product.imageUrl,
                                    fit: BoxFit.fitWidth,
                                    width: 180,
                                    height: 150,
                                  ),
                                  Text(
                                    product.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                    '${product.price.toStringAsFixed(2)} rs',
                                  ),
                                ],
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
                                  onPressed: () {
                                    if (isFavorite) {
                                      wishListProvider.removeProduct(
                                        product.id,
                                        "checkinglogin@gmail.com",
                                      );
                                    } else {
                                      final wishListProduct = WishListItems(
                                        id: product.id,
                                        title: product.title,
                                        price: product.price,
                                        imageUrl: "",
                                        description: product.description,
                                        rating: product.rating,
                                      );
                                      wishListProvider.addProduct(
                                        wishListProduct,
                                        "checkinglogin@gmail.com",
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
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
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                productProvider.searchProduct(controller.text);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchedProductsScreen(),
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

class _CategoryHeader extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 180;
  @override
  double get maxExtent => 180;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: TextStyle(fontSize: 18)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
