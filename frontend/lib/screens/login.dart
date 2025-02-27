// redirect to the registration page if the user is not logged in.

import 'dart:convert';
import 'package:ecommerce_provider/screens/products_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final uri = 'http://192.168.29.93:3000/';
final url = "${uri}login";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      var reqBody = {
        "email": _emailController.text,
        "password": _passwordController.text
      };

      var response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonReponse = jsonDecode(response.body);
      if (jsonReponse['status']) {
        var myToken = jsonReponse['token'];
        print(jsonReponse['token']);
        prefs.setString('token', myToken);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) => ProductsScreen(token: myToken)),
        ).then((_) {
          // This code will run after the navigation is complete
          print('Navigation complete');
        });
        //    await Navigator.push(
        // context,
        // MaterialPageRoute(builder: (context) => ProductsScreen(token: myToken)),
      } else {
        print("something went wrong");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Register button pressed
            //     print('Register button pressed');
            //     print('Email: ${_emailController.text}');
            //     print('Password: ${_passwordController.text}');
            //   },
            //   child: Text('Register'),
            // ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                loginUser();
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
