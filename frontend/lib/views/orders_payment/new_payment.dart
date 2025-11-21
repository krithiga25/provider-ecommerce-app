import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomPaymentPage extends StatefulWidget {
  const CustomPaymentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomPaymentPageState createState() => _CustomPaymentPageState();
}

class _CustomPaymentPageState extends State<CustomPaymentPage> {
  CardFieldInputDetails? _cardDetails;

  Future<void> payNow() async {
    try {
      if (_cardDetails == null || !_cardDetails!.complete) {
        print("Enter valid card details");
        return;
      }
      final response = await http.post(
        Uri.parse('$url/createpayment'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": "newcustomer@gmail.com",
          "name": "newcustomer",
          "amount": 5000,
        }),
      );
      final paymentData = jsonDecode(response.body);

      if (paymentData['error'] == true) {
        print("Error: ${paymentData['message']}");
        return;
      }

      final paymentIntent = paymentData['paymentIntent'];
      BillingDetails billingDetails = BillingDetails(
        address: Address(
          country: 'IN',
          city: 'Chennai',
          line1: 'addr1',
          line2: 'addr2',
          postalCode: '680681',
          state: 'kerala',
        ),
      );
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
        ),
      );
      print("Payment Successful!");
    } catch (e) {
      print("Payment Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Payment UI")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CardField(
              onCardChanged: (card) => setState(() => _cardDetails = card),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: payNow, child: Text("Pay Now")),
          ],
        ),
      ),
    );
  }
}
