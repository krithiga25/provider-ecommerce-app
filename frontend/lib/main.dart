import 'package:ecommerce_provider/providers/wish_list_provider.dart';
import 'package:ecommerce_provider/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/product_provider.dart';
import './providers/cart_provider.dart';
import 'screens/products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishListProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Provider Demo',
        theme: ThemeData(primarySwatch: Colors.green),
       // home: ProductsScreen(),
       home: RegistrationScreen(),
      ),
    );
  }
}
