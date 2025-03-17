import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/categories_products_screen.dart';
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
                      SliverToBoxAdapter(child: _categoryWidget(context)),
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
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      fit: BoxFit.cover,
                                      height: 200,
                                    ),
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
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors
                                                        .purpleAccent
                                                        .shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () async {
                                                final cartProduct = CartProduct(
                                                  id: product.id,
                                                  title: product.title,
                                                  price: product.price,
                                                  imageUrl: product.imageUrl,
                                                  description:
                                                      product.description,
                                                  rating: product.rating,
                                                );

                                                final status =
                                                    await cartProvider
                                                        .addProduct(
                                                          cartProduct,
                                                        );
                                                showCustomSnackBar(
                                                  context,
                                                  status
                                                      ? "Product added to cart!"
                                                      : "Failed to add to cart!",
                                                );
                                              },
                                              child: Text(
                                                "Add to Cart",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          if (isInCart)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              // padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed:
                                                        () => cartProvider
                                                            .decreaseQuantity(
                                                              product.id,
                                                            ),
                                                  ),
                                                  Text(
                                                    '$quantity',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed:
                                                        () => cartProvider
                                                            .increaseQuantity(
                                                              product.id,
                                                            ),
                                                  ),
                                                ],
                                              ),
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
                                                  product.id,
                                                  "checkinglogin@gmail.com",
                                                );
                                              } else {
                                                final wishlistProduct =
                                                    WishListItems(
                                                      id: product.id,
                                                      title: product.title,
                                                      price: product.price,
                                                      imageUrl:
                                                          product.imageUrl,
                                                      description:
                                                          product.description,
                                                      rating: product.rating,
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
      height: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Poupular products', style: TextStyle(fontSize: 18)),
          SizedBox(
            height: 300,
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
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CachedNetworkImage(
                                        // 'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-images/electronics/headphones.jpg',
                                        // 'https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-pdf-bucket//jacket2.jpg',
                                        //'assets/iphone.jpg',
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.fitWidth,
                                        height: 150,
                                        // width:
                                        //     MediaQuery.of(context).size.width *
                                        //     0.3,
                                        //width: 150,
                                      ),
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
                                        imageUrl:
                                            "https://hhatffzhvdmybvizyvhw.supabase.co/storage/v1/object/public/flut-pdf-bucket//jacket2.jpg",
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
              onPressed: () async {
                // here added await, cause in the search page, page is built before the response is recieved and the page is empty.
                await productProvider.searchProduct(controller.text);
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

List<CategoriesList> _categoriesList = [
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
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
    height: 250,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: TextStyle(fontSize: 18)),
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
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          imageUrl: category.categoryImageUrl,
                          fit: BoxFit.fitWidth,
                          width: 150,
                          height: 150,
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

class CategoriesList {
  final String categoryName;
  final String categoryImageUrl;

  CategoriesList({required this.categoryName, required this.categoryImageUrl});
}
