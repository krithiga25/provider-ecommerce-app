import 'dart:convert';

import 'package:ecommerce_provider/views/login_register/login.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();
  //bool _isValidate = false;
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  void _registerUser() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      var regBody = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };
      var response = await http.post(
        Uri.parse('$url/registration'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      var jsonReponse = jsonDecode(response.body);
      if (jsonReponse['status']) {
        showCustomSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'Signed in successfully!',
          color: Colors.green.shade600,
          duration: 2,
        );
        await Future.delayed(Duration(seconds: 2));
        showCustomSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'Taking you to Login Page',
          color: Colors.black,
          duration: 2,
        );
        await Future.delayed(Duration(seconds: 3));
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
        //set some notification - logged in!
      } else {
        _emailController.clear();
        _passwordController.clear();
        _userNameController.clear();
        showCustomSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'Something went wrong, please try again!',
          color: Colors.red,
        );
      }
    }
    // else {
    //   setState(() {
    //     _isValidate = true;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  'Register, Now',
                  style: GoogleFonts.openSans(
                    fontSize: 60,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        //labelText: 'Username',
                        hintText: 'Enter your Name',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.blueGrey,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.blueGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey,
                            width: 2,
                          ), // On focus
                        ),
                        errorStyle: GoogleFonts.openSans(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your E-mail',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.blueGrey,
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.blueGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey,
                            width: 2,
                          ), // On focus
                        ),
                        errorStyle: GoogleFonts.openSans(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid Email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        //labelText: 'Password',
                        hintText: 'Enter a Password',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.blueGrey,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.blueGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blueGrey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                              // visibilityIcon = Icons.visibility;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey,
                            width: 2,
                          ), // On focus
                        ),
                        errorStyle: GoogleFonts.openSans(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter a Password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blueGrey),
                  ),
                  onPressed: () async {
                    // Register button pressed
                    // print('Register button pressed');
                    // print('Email: ${_emailController.text}');
                    // print('Password: ${_passwordController.text}');
                    if (_formKey.currentState!.validate()) {
                      if (_passwordController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty) {
                        _registerUser();
                      }
                    }
                  },
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a user?',
                    style: GoogleFonts.openSans(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.openSans(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopNotification extends StatefulWidget {
  const TopNotification({super.key});

  @override
  _TopNotificationState createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification> {
  bool _isVisible = false;

  void showNotification() {
    setState(() {
      _isVisible = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your page content here
          Positioned(
            top: _isVisible ? 0 : -50,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.green,
              padding: EdgeInsets.all(16),
              child: Text(
                'Successfully logged in!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        child: Icon(Icons.check),
      ),
    );
  }
}
