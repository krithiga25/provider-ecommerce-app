import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final cartProvider = Provider.of<CartProvider>(context);
    // final cartProducts = cartProvider.cartItems; // Get the product list

    return Scaffold(
      appBar: AppBar(title: Text('Cart screen')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartProducts;

          return cartItems.isEmpty
              ? Center(child: Text('Your cart is empty!'))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, index) {
                    final item = cartItems[index];
                    final quantity = cartProvider.getQuantity(item.id);
                    return Card(
                      child: Column(
                        children: [
                          Text(item.title),
                          Text('\$${item.price.toStringAsFixed(2)}'),
                          Row(children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.decreaseQuantity(item.id);
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                cartProvider.increaseQuantity(item.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cartProvider.removeProduct(item.id);
                              },
                            ),
                          ]),
                          //this will lead to the order page consisting of all the order items and then a payment method?
                          // for now => the list of cart items will be put in the orders page as in Map Data strcuture, with oder id as the key.
                          TextButton(
                              onPressed: () {},
                              child: Text("Procced to place order")),
                          TextButton(
                              onPressed: () {}, child: Text("Move to wishlist"))
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
