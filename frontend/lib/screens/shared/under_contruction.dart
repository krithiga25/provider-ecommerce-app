import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';

class UnderContruction extends StatefulWidget {
  const UnderContruction({super.key});

  @override
  State<UnderContruction> createState() => _UnderContructionState();
}

class _UnderContructionState extends State<UnderContruction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: RiveAnimation.asset(
              'assets/login_screen_character.riv',
              // artboard: 'default',
            ), // Load Rive animation
          ),
          Text(
            "Hi, the page you are looking for might be under construction!",
            style: GoogleFonts.openSans(color: Colors.black, height: 1.5),
          ),
        ],
      ),
    );
  }
}
