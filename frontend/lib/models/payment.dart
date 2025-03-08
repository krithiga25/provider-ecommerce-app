import 'dart:convert';
import 'package:ecommerce_provider/screens/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// need to check the issue without retrieving the customer object.
Future<String> initPaymentSheet(double amount) async {
  String status = '';
  try {
    var reqBody = {
      "email": "newcustomer@gmail.com",
      "name": "newcustomer",
      "amount": amount
    };
    final response = await http.post(
      Uri.parse('$url/createpayment'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );
    var data = jsonDecode(response.body);

    final paymentIntent = data['paymentIntent'];
    final ephemeralKey = data['ephemeralKey'];
    final customer = data['customer'];
    final publishableKey = data['publishableKey'];

    Stripe.publishableKey = publishableKey;
    BillingDetails billingDetails = BillingDetails(
      address: Address(
        country: 'IN',
        city: 'Chennai',
        line1: 'addr1',
        line2: 'addr2',
        postalCode: '680681',
        state: 'kerala',
        // Other address details
      ),
      // Other billing details
    );
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'KRITHIGA',
          paymentIntentClientSecret: paymentIntent,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customer,
          style: ThemeMode.light,
          billingDetails: billingDetails,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'IN',
            currencyCode: 'inr',
            testEnv: true,
          ),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
    await Stripe.instance
        .presentPaymentSheet()
        .then((value) {
          status = "success";
        })
        .onError((error, stackTrace) {
          if (error is StripeException) {
            // ScaffoldMessenger.of().showSnackBar(
            //   SnackBar(content: Text('${error.error.localizedMessage}')),
            // );
            status = ('${error.error.localizedMessage}');
            print('${error.error.localizedMessage}');
          } else {
            // ScaffoldMessenger.of(Get.context!).showSnackBar(
            //   SnackBar(content: Text('Stripe Error: $error')),
            // );
            status = ('Stripe Error: $error');
            print('Stripe Error: $error');
          }
        });
    return status;
  } catch (e) {
    // ScaffoldMessenger.of(Get.context!).showSnackBar(
    //   SnackBar(content: Text('Error initializing payment: $e')),
    // );
    // ScaffoldMessenger.of(Get.context!).showSnackBar(
    //   SnackBar(content: Text(e.toString())),
    // );
    print('Error initializing payment: $e');
    return ('Error initializing payment: $e');
  }
}
