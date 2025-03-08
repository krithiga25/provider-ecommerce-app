import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/cart_screen.dart';
import 'package:ecommerce_provider/screens/orders_screen.dart';
import 'package:ecommerce_provider/screens/products_screen.dart';
import 'package:ecommerce_provider/screens/wish_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final url =
    //'http://192.168.29.93:3000'
    'https://fs-ecommerce-app.onrender.com';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    Provider.of<WishListProvider>(
      context,
      listen: false,
    ).fetchWishlistProducts("checkinglogin@gmail.com");
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).fetchCartProducts("checkinglogin@gmail.com");
  }

  int currentPageIndex = 0;
  CartProvider cartProvider = CartProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.purpleAccent.shade100,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(label: 'Home', icon: Icon(Icons.home_outlined)),
          NavigationDestination(label: 'wishlist', icon: Icon(Icons.favorite)),
          NavigationDestination(
            label: 'cart',
            icon: Badge(
              label: Text('2'),
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.shopping_cart),
            ),
          ),
          NavigationDestination(label: 'Orders', icon: Icon(Icons.receipt)),
        ],
      ),
      body:
          <Widget>[
            /// Home page
            ProductsScreen(),

            /// wishlist page
            WishListScreen(),

            /// cart screen
            CartScreen(),

            /// orders page:
            OrdersPage(),
          ][currentPageIndex],
    );
  }
}


    void showCustomSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(16),
      elevation: 6,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
