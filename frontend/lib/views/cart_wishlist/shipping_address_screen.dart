import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/models/payment.dart';
import 'package:ecommerce_provider/providers/cart_provider.dart';
import 'package:ecommerce_provider/providers/orders_provider.dart';
import 'package:ecommerce_provider/views/cart_wishlist/cart_screen.dart';
import 'package:ecommerce_provider/views/orders_payment/splash_screen.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingAddressScreen extends StatefulWidget {
  final String email;
  const ShippingAddressScreen({super.key, required this.email});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  late SharedPreferences prefs;

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('currentuser') ?? '';
    if (!mounted) return;
    Provider.of<CartProvider>(context, listen: false).getAddress(email);
  }

  @override
  Widget build(BuildContext context) {
    OrdersProvider ordersProvider = Provider.of<OrdersProvider>(
      context,
      listen: false,
    );
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartProducts;
        return Scaffold(
          backgroundColor: Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: Color(0xFFF7F7F7),
            title: Text(
              "ADDRESS",
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Color(0xFFF7F7F7),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(),
              ),
              onPressed: () async {
                double totalQuantity = cartItems.fold(0, (a, b) => a + b.price);
                final status = await initPaymentSheet(totalQuantity);
                if (status == "success") {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              OrderStatusSplashScreen(status: 'success'),
                    ),
                  );
                  cartProvider.clearCart(widget.email);
                  final status = await ordersProvider.createOrder(
                    user: widget.email,
                    products: cartItems,
                    paymentMethod: "credit card",
                    paymentStatus: "paid",
                    subTotal: cartItems.fold(0, (a, b) => a + b.price),
                    tax:
                        (cartItems.fold(0, (a, b) => a + b.price) * 0.18)
                            .round(),
                    total: cartItems.fold(0, (a, b) => a + b.price) + 50,
                  );
                  if (status) {
                    Future.delayed(Duration(milliseconds: 2000), () {
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => NavigationExample(initialIndex: 3),
                        ),
                        (route) => false,
                      );
                    });
                  }
                } else {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              OrderStatusSplashScreen(status: 'failed'),
                    ),
                  );
                  Future.delayed(Duration(milliseconds: 2000), () {
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => NavigationExample(initialIndex: 2),
                      ),
                      (route) => false,
                    );
                  });
                }
              },
              child: Text(
                "CONTINUE TO PAYMENT",
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              if (cartProvider.userAddress?.shippingAddress == null ||
                  cartProvider.userAddress?.shippingAddress.name == null ||
                  cartProvider.userAddress?.shippingAddress.name.isEmpty ==
                      true)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40,
                          bottom: 10,
                          top: 40,
                        ),
                        child: Text(
                          "No default address found. Please add one.",
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 100, bottom: 15),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(),
                          ),
                          child: Text(
                            "ADD NEW ADDRESS",
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    contentPadding: EdgeInsets.only(
                                      left: 40,
                                      right: 40,
                                      bottom: 20,
                                    ),
                                    title: Row(
                                      children: [
                                        Text("Add New Address"),
                                        IconButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          icon: Icon(Icons.cancel_outlined),
                                        ),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: _addressForm(context),
                                    ),
                                  ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 15),
                        child: Text(
                          " DELIVERY ESTIMATES",
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (cartProvider.userAddress?.shippingAddress != null)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          bottom: 10,
                          top: 10,
                        ),
                        child: Text(
                          "DEFAULT",
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 50,
                          left: 20,
                          right: 20,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.only(
                            left: 16,
                            bottom: 35,
                            top: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    cartProvider
                                        .userAddress!
                                        .shippingAddress
                                        .name,
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "(Default)",
                                    style: GoogleFonts.openSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                ],
                              ),
                              SizedBox(height: 7),
                              if (cartProvider.userAddress != null)
                                Text(
                                  "${cartProvider.userAddress!.shippingAddress.address}\n${cartProvider.userAddress!.shippingAddress.city}\n${cartProvider.userAddress!.shippingAddress.state}\n${cartProvider.userAddress!.shippingAddress.zip}\n${cartProvider.userAddress!.shippingAddress.country}",
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 15),
                        child: Text(
                          " DELIVERY ESTIMATES",
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: cartItems.length,
                  (ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          tileColor: Colors.white,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: cartItems[index].imageUrl,
                                width: 70,
                                height: 70,
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  'Estimated delivery by ${cartItems[index].estimatedDeliveryDate!.day.toString()} ${getMonth(cartItems[index].estimatedDeliveryDate!.month)} ${cartItems[index].estimatedDeliveryDate!.year.toString()}',
                                  style: GoogleFonts.openSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _addressForm(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController zipController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // TextFormField(
          //   decoration: InputDecoration(labelText: 'Email'),
          //   onSaved: (value) => email = value!,
          // ),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'City'),
            controller: cityController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'State'),
            controller: stateController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Zip'),
            controller: zipController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Country'),
            controller: countryController,
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty &&
                  cityController.text.isNotEmpty &&
                  stateController.text.isNotEmpty &&
                  zipController.text.isNotEmpty &&
                  countryController.text.isNotEmpty) {
                _formKey.currentState!.save();
                Map<String, dynamic> data = {
                  "email": email,
                  "shippingAddress": {
                    "name": nameController.text,
                    "address": addressController.text,
                    "city": cityController.text,
                    "state": stateController.text,
                    "zip": zipController.text,
                    "country": countryController.text,
                  },
                };
                Provider.of<CartProvider>(
                  context,
                  listen: false,
                ).updateAddress(data);
              }
              Navigator.pop(context);
            },
            child: Text('UPDATE', style: GoogleFonts.openSans()),
          ),
        ],
      ),
    );
  }
}
