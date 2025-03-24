// redirect to the registration page if the user is not logged in.

import 'dart:convert';

import 'package:ecommerce_provider/screens/login_register/login.dart';
import 'package:ecommerce_provider/screens/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isValidate = false;
  void registerUser() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      var regBody = {
        "email": _emailController.text,
        "password": _passwordController.text
      };

      var response = await http.post(Uri.parse('$url/registration'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));
      var jsonReponse = jsonDecode(response.body);
      // returns true.
      print(jsonReponse['status']);
      if (jsonReponse['status']) {
        Navigator.push(
            // ignore: use_build_context_synchronously
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
        //set some notification - logged in!
      } else {
        print("something went wrong");
        //provide a snackbar.
      }
    } else {
      setState(() {
        _isValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
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
                      errorText: _isValidate
                          ? "Please enter an email to register"
                          : null,
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
                      errorText: _isValidate
                          ? "Please enter password to register"
                          : null,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Register button pressed
                print('Register button pressed');
                print('Email: ${_emailController.text}');
                print('Password: ${_passwordController.text}');
                registerUser();
              },
              child: Text('Register'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// class TopNotification extends StatefulWidget {
//   @override
//   _TopNotificationState createState() => _TopNotificationState();
// }

// class _TopNotificationState extends State<TopNotification> {
//   bool _isVisible = false;

//   void showNotification() {
//     setState(() {
//       _isVisible = true;
//     });
//     Future.delayed(Duration(seconds: 2), () {
//       setState(() {
//         _isVisible = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Your page content here
//           Positioned(
//             top: _isVisible ? 0 : -50,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.green,
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 'Successfully logged in!',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: showNotification,
//         child: Icon(Icons.check),
//       ),
//     );
//   }
// }
