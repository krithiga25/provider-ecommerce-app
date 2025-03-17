import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/product.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/cart_screen.dart';
import 'package:ecommerce_provider/screens/shared.dart';
import 'package:ecommerce_provider/screens/wish_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.categoryName});
  final String categoryName;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> sortedProducts = [];
  List<Product> _originalProducts = [];
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(50, 5000);
  bool _showFilterPanel = false;
  int _selectedFilterIndex = 0;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    _originalProducts =
        productProvider.products
            .where((product) => product.category == widget.categoryName)
            .toList();
    sortedProducts = _originalProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishListScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        automaticallyImplyLeading: false,
        title: Text('Search for "${widget.categoryName}"'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Consumer<WishListProvider>(
            builder: (context, wishListProvider, child) {
              return Stack(
                children: [
                  sortedProducts.isEmpty
                      ? Center(
                        child: Text('Can not find products for your search!'),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.only(top: 60, bottom: 60),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 320,
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        itemCount: sortedProducts.length,
                        itemBuilder: (ctx, index) {
                          final item = sortedProducts[index];
                          final isFavorite = wishListProvider.isFavorite(
                            item.id,
                          );
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.fitWidth,
                                    width: 140,
                                    height: 200,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(item.title),
                                    Text('\$${item.price.toStringAsFixed(2)}'),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          child: Text("Add to cart"),
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
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFavorite ? Colors.red : null,
                                          ),
                                          onPressed: () async {
                                            if (isFavorite) {
                                              wishListProvider.removeProduct(
                                                item.id,
                                                "checkinglogin@gmail.com",
                                              );
                                            } else {
                                              final wishlistProduct =
                                                  WishListItems(
                                                    id: item.id,
                                                    title: item.title,
                                                    price: item.price,
                                                    imageUrl: item.imageUrl,
                                                    description:
                                                        item.description,
                                                    rating: item.rating,
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
                          );
                        },
                      ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Sort Button
                          TextButton(
                            onPressed: () => _showSortOptions(context),
                            child: Row(
                              children: [
                                Icon(Icons.sort, size: 18),
                                SizedBox(width: 5),
                                Text("Sort"),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showFilterPanel = true;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.filter_list, size: 18),
                                SizedBox(width: 5),
                                Text("Filter"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showFilterPanel)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFilterPanel = false;
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              NavigationRail(
                                selectedIndex: _selectedFilterIndex,
                                onDestinationSelected: (index) {
                                  setState(() {
                                    _selectedFilterIndex = index;
                                  });
                                },
                                labelType: NavigationRailLabelType.all,
                                destinations: const [
                                  // NavigationRailDestination(
                                  //   padding: EdgeInsets.only(
                                  //     left: 25,
                                  //     right: 25,
                                  //   ),
                                  //   icon: Icon(Icons.category),
                                  //   label: Text('Category'),
                                  // ),
                                  NavigationRailDestination(
                                    padding: EdgeInsets.only(
                                      left: 25,
                                      right: 25,
                                    ),
                                    icon: Icon(Icons.attach_money),
                                    label: Text('Price'),
                                  ),
                                  NavigationRailDestination(
                                    padding: EdgeInsets.only(
                                      left: 25,
                                      right: 25,
                                    ),
                                    icon: Icon(Icons.star),
                                    label: Text('Rating'),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      _buildFilterOptions(),
                                      ElevatedButton(
                                        onPressed: () {
                                          _applyFilters();
                                          setState(() {
                                            _showFilterPanel = false;
                                          });
                                        },
                                        child: const Text('Apply'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      //},
    );
    //   },
    // );
  }

  Widget _buildFilterOptions() {
    switch (_selectedFilterIndex) {
      // no category case, since it is already from the category data.
      // case 0:
      //   return _buildCategoryFilter();
      case 0:
        return _buildPriceFilter();
      case 1:
        return _buildRatingFilter();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Price Range:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RangeSlider(
          values: _priceRange,
          min: 50,
          max: 5000,
          divisions: 59,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Rating:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < (_selectedRating ?? 0) ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _selectedRating = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  void _applyFilters() {
    setState(() {
      sortedProducts =
          _originalProducts.where((product) {
            if (_selectedCategory != null &&
                product.category != _selectedCategory!.toLowerCase()) {
              return false;
            }
            if (product.price < _priceRange.start ||
                product.price > _priceRange.end) {
              return false;
            }
            //kept it as rating greater and equal to the selected rating
            if (_selectedRating != null && product.rating < _selectedRating!) {
              return false;
            }
            return true;
          }).toList();
    });
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // List<Product> products = productsList.map((e) => e as Product).toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Price: Low to High'),
              onTap: () {
                setState(() {
                  sortedProducts.sort((a, b) => a.price.compareTo(b.price));
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text('Price: High to Low'),
              onTap: () {
                setState(() {
                  sortedProducts.sort((a, b) => b.price.compareTo(a.price));
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text('Rating: High to Low'),
              onTap: () {
                setState(() {
                  sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text('Most Popular'),
              onTap: () {
                setState(() {
                  sortedProducts.sort(
                    (a, b) => b.ratingCount.compareTo(a.ratingCount),
                  );
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text('Alphabetical (A to Z)'),
              onTap: () {
                setState(() {
                  sortedProducts.sort((a, b) => a.title.compareTo(b.title));
                });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text('Alphabetical (Z to A)'),
              onTap: () {
                setState(() {
                  sortedProducts.sort((a, b) => b.title.compareTo(a.title));
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }
}
