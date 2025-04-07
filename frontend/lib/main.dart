import 'package:ecommerce_provider/providers/orders_provider.dart';
import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/views/login_register/login.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import './providers/product_provider.dart';
import './providers/cart_provider.dart';
//import 'screens/products_screen.dart';

void main() {
  // for new payment.dart
  // Stripe.publishableKey =
  //     'pk_test_51QvBubL4gE1upbxJftPvLWy2vQBXi1ciQwgS4eaZBQY9iV9m49N5BtSIK84nc9R7ruiHQau2GFm8fkmx7kNLmRZk00ZGZaIetJ';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishListProvider()),
        ChangeNotifierProvider(create: (context) => OrdersProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Provider Demo',
        //theme: ThemeData.dark(),
        home: NavigationExample(),
        // home: LoginScreen(),
      ),
    );
  }
}
