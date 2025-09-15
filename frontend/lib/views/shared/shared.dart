import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/orders_provider.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/ai-assistant/chat_view.dart';
import 'package:ecommerce_provider/views/cart_wishlist/cart_screen.dart';
import 'package:ecommerce_provider/views/orders_payment/orders_screen.dart';
import 'package:ecommerce_provider/views/products/products_screen.dart';
import 'package:ecommerce_provider/views/cart_wishlist/wish_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final url =
    //'http://192.168.29.93:3000'
    //'https://fs-ecommerce-app.onrender.com';
    'http://65.2.4.71:3000';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key, this.token, this.initialIndex});

  final token;
  final int? initialIndex;

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  @override
  void initState() {
    if (widget.initialIndex != null) {
      currentPageIndex = widget.initialIndex!;
    }
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
    Provider.of<OrdersProvider>(
      context,
      listen: false,
    ).fetchOrders("krithiperu2002@gmail.com");
    //Provider.of<OrdersProvider>(context, listen: false).updateDeliveryStatus();
  }

  int currentPageIndex = 0;
  CartProvider cartProvider = CartProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // backgroundColor: Color(0xFFFFFFFF),
      //   title: Text(currentPageIndex == 1 ? 'Wishlist' : 'Home'),
      //   automaticallyImplyLeading: false,

      // ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color(0xFFF7F7F7),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blueGrey.shade300,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(label: 'Home', icon: Icon(Icons.home_outlined)),
          NavigationDestination(label: 'wishlist', icon: Icon(Icons.favorite)),
          NavigationDestination(label: 'cart', icon: Icon(Icons.shopping_cart)),
          NavigationDestination(label: 'Orders', icon: Icon(Icons.receipt)),
          NavigationDestination(label: 'Assistant', icon: Icon(Icons.man_3_sharp)),
        ],
      ),
      body:
          <Widget>[
            /// Home page
            ProductsScreen(token: widget.token),
            //ProductsScreen(),

            /// wishlist page
            WishListScreen(),

            /// cart screen
            CartScreen(token: widget.token),

            /// orders page:
            OrdersPage(),

            //assistant page:
            ChatScreen(),
          ][currentPageIndex],
    );
  }
}

void showCustomSnackBar(BuildContext context, String message, {Color? color}) {
  final snackBar = SnackBar(
    content: Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
    backgroundColor: color ?? Colors.black87,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: EdgeInsets.all(16),
    elevation: 6,
    duration: Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget buildStep(String label, bool coloredIndex) {
  return Row(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: coloredIndex ? Colors.green : Colors.white,
              border: Border.all(color: Colors.green, width: 1),
            ),
          ),
          if (coloredIndex)
            Icon(Icons.check, size: 6, color: Colors.white)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
        ],
      ),
      Text(
        label,
        style: TextStyle(
          color: coloredIndex ? Colors.green : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    ],
  );
}

Container buildLine(double width, bool coloredIndex) {
  return Container(
    height: 2,
    width: width,
    color: coloredIndex ? Colors.green : Colors.grey,
  );
}
