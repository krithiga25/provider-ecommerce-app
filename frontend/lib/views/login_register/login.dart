import 'dart:async';
import 'dart:convert';
import 'package:ecommerce_provider/views/login_register/register.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:ecommerce_provider/views/shared/under_contruction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late SharedPreferences prefs;
  late RiveAnimationController _controller;
  final String _currentAnimation = 'look_idle';
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  Timer? typingTimer;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isButtonPressed = false;
  // ignore: prefer_typing_uninitialized_variables
  var myToken;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    _controller = SimpleAnimation(_currentAnimation);
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _changeAnimation('hands_up');
      } else {
        _changeAnimation('hands_down');
      }
    });
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loginUser() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      var reqBody = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      var response = await http.post(
        Uri.parse('$url/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      var jsonReponse = jsonDecode(response.body);
      if (jsonReponse['status']) {
        myToken = jsonReponse['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(myToken);
        final email = decodedToken['email'];
        //final email = "shiro@gmail.com";
        await prefs.setString('currentuser', email);
        _changeAnimation('success');
        if (!mounted) return;
        showCustomSnackBar(
          context,
          'Login Successful!!',
          color: Colors.green.shade600,
        );
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(Duration(seconds: 6));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationExample(),
          ),
          (route) => false,
        );
      } else {
        _changeAnimation('fail');
        if (!mounted) return;
        showCustomSnackBar(
          context,
          'Invalid credinationals, please try again!',
          color: Colors.red,
        );
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _isButtonPressed = false;
        });
      }
    }
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
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  'Holla, amigo!',
                  style: GoogleFonts.openSans(
                    fontSize: 30,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 380,
                child: RiveAnimation.asset(
                  'assets/login_no_bg.riv',
                  controllers: [_controller],
                  stateMachines: [
                    'State Machine 1',
                  ], // Add the state machine name
                  onInit: (Artboard artboard) {
                    var controller = StateMachineController.fromArtboard(
                      artboard,
                      _currentAnimation,
                    );
                    if (controller != null) {
                      artboard.addController(controller);
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
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
                          ), 
                        ),
                        errorStyle: GoogleFonts.openSans(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                          ),
                        ),
                        errorStyle: GoogleFonts.openSans(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnderContruction(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.openSans(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  onPressed:
                      _isButtonPressed
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_passwordController.text.isNotEmpty &&
                                  _emailController.text.isNotEmpty) {
                                setState(() {
                                  _isButtonPressed = true;
                                });
                                await loginUser();
                              }
                            }
                          },
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.openSans(
                      color: _isButtonPressed ? Colors.white60 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\tt have an account?',
                    style: GoogleFonts.openSans(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.openSans(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(color: Colors.blueGrey),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  void _changeAnimation(String animationName) {
    setState(() {
      _controller.isActive = false;
      _controller = SimpleAnimation(animationName, autoplay: true);
    });
    _controller.isActive = true;
  }
}
