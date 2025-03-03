import 'package:ecommerce_provider/screens/cart_screen.dart';
import 'package:ecommerce_provider/screens/orders_screen.dart';
import 'package:ecommerce_provider/screens/products_screen.dart';
import 'package:ecommerce_provider/screens/wish_list_screen.dart';
import 'package:flutter/material.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          NavigationDestination(
            label: 'wishlist',
            icon: Icon(Icons.favorite),
          ),
          NavigationDestination(
            label: 'cart',
            icon: Icon(Icons.shopping_cart),
          ),
          NavigationDestination(
            label: 'Profile',
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: <Widget>[
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
