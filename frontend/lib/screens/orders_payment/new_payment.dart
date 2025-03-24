import 'package:ecommerce_provider/screens/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomPaymentPage extends StatefulWidget {
  @override
  _CustomPaymentPageState createState() => _CustomPaymentPageState();
}

class _CustomPaymentPageState extends State<CustomPaymentPage> {
  CardFieldInputDetails? _cardDetails;

  Future<void> payNow() async {
    try {
      // Step 1: Collect Card Details
      if (_cardDetails == null || !_cardDetails!.complete) {
        print("Enter valid card details");
        return;
      }

      // Step 2: Create Payment Intent on Backend
      final response = await http.post(
        Uri.parse('$url/createpayment'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": "newcustomer@gmail.com",
          "name": "newcustomer",
          "amount": 5000, // Amount in smallest currency unit (e.g., paise)
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
          // Other address details
        ),
        // Other billing details
      );
      // Step 3: Confirm Payment with Card Details
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
