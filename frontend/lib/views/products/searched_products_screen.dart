import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/cart.dart';
import 'package:ecommerce_provider/models/product.dart';
import 'package:ecommerce_provider/models/wish_list.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/products/products_screen.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchedProductsScreen extends StatefulWidget {
  const SearchedProductsScreen({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  State<SearchedProductsScreen> createState() => _SearchedProductsScreenState();
}

class _SearchedProductsScreenState extends State<SearchedProductsScreen> {
  List<Product> sortedProducts = [];
  List<Product> _originalProducts = [];
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(50, 30000);
  bool _showFilterPanel = false;
  int _selectedFilterIndex = 0;
  int? _selectedRating;
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    _originalProducts = productProvider.searchProducts;
    sortedProducts = _originalProducts;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F7),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NavigationExample(initialIndex: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NavigationExample(initialIndex: 2),
                ),
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
        title: Text(
          'Search for "${widget.searchQuery}"',
          style: GoogleFonts.openSans(
            color: Colors.blueGrey,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body:
      // Consumer<ProductProvider>(
      //   builder: (context, productProvider, child) {
      //final productsList = productProvider.searchProducts;
      Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Consumer<WishListProvider>(
            builder: (context, wishListProvider, child) {
              return sortedProducts.isEmpty && productProvider.searchResults
                  ? Center(child: loadingAnimation())
                  : sortedProducts.isEmpty &&
                      !productProvider.searchResults &&
                      !_isFilterApplied
                  ? Center(child: Text('No search results for this!'))
                  : _isFilterApplied
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Center(child: Text('No search results for this!')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF7F7F7),
                        ),
                        onPressed: () {
                          _resetFilters();
                        },
                        child: Text(
                          'Reset filters',
                          style: GoogleFonts.openSans(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Stack(
                    children: [
                      // ? Center(
                      //   child: Text('Can not find products for your search!'),
                      // ):
                      GridView.builder(
                        padding: const EdgeInsets.only(
                          top: 60,
                          bottom: 60,
                          right: 5,
                          left: 5,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 330,
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        itemCount: sortedProducts.length,
                        itemBuilder: (ctx, index) {
                          final item = sortedProducts[index];
                          final isFavorite = wishListProvider.isFavorite(
                            item.id,
                          );
                          final isInCart = cartProvider.isInCart(item.id);
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Column(
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
                                        Text(
                                          item.title,
                                          style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '\u{20B9} ${item.price.toStringAsFixed(2)}',
                                          style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (!isInCart)
                                              TextButton(
                                                child: Text(
                                                  "ADD TO CART",
                                                  style: GoogleFonts.openSans(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  final cartProduct =
                                                      CartProduct(
                                                        id: item.id,
                                                        title: item.title,
                                                        price: item.price,
                                                        imageUrl: item.imageUrl,
                                                        description:
                                                            item.description,
                                                        rating: item.rating,
                                                      );

                                                  final status =
                                                      await cartProvider
                                                          .addProduct(
                                                            cartProduct,
                                                          );
                                                  Future.delayed(
                                                    Duration(milliseconds: 500),
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
                                              ),
                                            if (isInCart)
                                              Container(
                                                height: 35,
                                                width: 105,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.remove,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed:
                                                          () => cartProvider
                                                              .decreaseQuantity(
                                                                item.id,
                                                              ),
                                                    ),
                                                    Text(
                                                      '${cartProvider.getQuantity(item.id)}',
                                                      style:
                                                          GoogleFonts.openSans(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed:
                                                          () => cartProvider
                                                              .increaseQuantity(
                                                                item.id,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
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
                                              item.id,
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
                                          id: item.id,
                                          title: item.title,
                                          price: item.price,
                                          imageUrl: item.imageUrl,
                                          description: item.description,
                                          rating: item.rating,
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
                                Positioned(
                                  left: 7,
                                  top: 7,
                                  child: Card(
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 5),
                                        Text(
                                          item.rating.toString(),
                                          style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                  ),
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
                                    Icon(
                                      Icons.sort,
                                      size: 20,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Sort",
                                      style: GoogleFonts.openSans(
                                        color: Colors.blueGrey,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
                                    Icon(
                                      Icons.filter_list,
                                      size: 20,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Filter",
                                      style: GoogleFonts.openSans(
                                        color: Colors.blueGrey,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
                              color: Color(0xFFF7F7F7),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  NavigationRail(
                                    indicatorColor: Colors.blueGrey.shade300,
                                    backgroundColor: Color(0xFFF7F7F7),
                                    selectedIndex: _selectedFilterIndex,
                                    onDestinationSelected: (index) {
                                      setState(() {
                                        _selectedFilterIndex = index;
                                      });
                                    },
                                    labelType: NavigationRailLabelType.all,
                                    destinations: const [
                                      NavigationRailDestination(
                                        padding: EdgeInsets.only(
                                          left: 25,
                                          right: 25,
                                        ),
                                        icon: Icon(Icons.category),
                                        label: Text('Category'),
                                      ),
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
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 50,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor: Color(
                                                          0xFFF7F7F7,
                                                        ),
                                                      ),
                                                  onPressed: () {
                                                    _applyFilters();
                                                    setState(() {
                                                      _showFilterPanel = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Apply',
                                                    style: GoogleFonts.openSans(
                                                      color: Colors.blueGrey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor: Color(
                                                          0xFFF7F7F7,
                                                        ),
                                                      ),
                                                  onPressed:
                                                      _isFilterApplied
                                                          ? () {
                                                            _resetFilters();
                                                          }
                                                          : null,
                                                  child: Text(
                                                    'Reset filters',
                                                    style: GoogleFonts.openSans(
                                                      color: Colors.blueGrey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
      //   },
      // ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _priceRange = const RangeValues(50, 3000);
      _selectedRating = null;

      sortedProducts = List.from(_originalProducts);
      _isFilterApplied = false;

      _showFilterPanel = false;
    });
  }

  Widget _buildFilterOptions() {
    switch (_selectedFilterIndex) {
      case 0:
        return _buildCategoryFilter();
      case 1:
        return _buildPriceFilter();
      case 2:
        return _buildRatingFilter();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...['Footwear', 'Clothes', 'Accessories', 'Electronics'].map((
          category,
        ) {
          return CheckboxListTile(
            value: _selectedCategory == category,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value! ? category : null;
              });
            },
            title: Text(category),
          );
        }),
      ],
    );
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
          max: 30000,
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

      _isFilterApplied =
          _selectedCategory != null ||
          _priceRange != const RangeValues(50, 3000) ||
          _selectedRating != null;

      _showFilterPanel = false;
    });
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      //constraints: BoxConstraints(maxHeight: 800),
      backgroundColor: Colors.white,
      context: context,
      shape: BeveledRectangleBorder(),
      builder: (ctx) {
        // List<Product> products = productsList.map((e) => e as Product).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'SORT BY',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              ),
              Divider(thickness: 1),
              ListTile(
                title: Text(
                  'Price: Low to High',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    sortedProducts.sort((a, b) => a.price.compareTo(b.price));
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'Price: High to Low',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    sortedProducts.sort((a, b) => b.price.compareTo(a.price));
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'Rating: High to Low',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'Most Popular',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
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
                title: Text(
                  'Alphabetical (A to Z)',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    sortedProducts.sort((a, b) => a.title.compareTo(b.title));
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  'Alphabetical (Z to A)',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                onTap: () {
                  setState(() {
                    sortedProducts.sort((a, b) => b.title.compareTo(a.title));
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
