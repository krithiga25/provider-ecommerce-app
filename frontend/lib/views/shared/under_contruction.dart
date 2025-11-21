import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';

class UnderConstruction extends StatefulWidget {
  const UnderConstruction({super.key});

  @override
  State<UnderConstruction> createState() => _UnderConstructionState();
}

class _UnderConstructionState extends State<UnderConstruction> {
  late RiveAnimationController _controller;
  String _currentAnimation = 'look_idle'; // Default animation

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation(_currentAnimation);
  }

  void _changeAnimation(String animationName) {
    setState(() {
      _controller.isActive = false; // Stop the current animation
      _controller = SimpleAnimation(animationName, autoplay: true);
    });
    _controller.isActive = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rive Animation Example")),
      body: Column(
        children: [
          Expanded(
            child: RiveAnimation.asset(
              // 'assets/animated_login_character.riv',
              //'assets/login_screen_character.riv',
              'assets/login_no_bg.riv',
              controllers: [_controller],
              stateMachines: ['State Machine 1'], // Add the state machine name
              onInit: (Artboard artboard) {
                var controller = StateMachineController.fromArtboard(
                  artboard,
                  _currentAnimation, //need to give the animation name here.
                );
                if (controller != null) {
                  artboard.addController(controller);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _changeAnimation('success'),
                  child: Text("Success"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _changeAnimation('fail'),
                  child: Text("Fail"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _changeAnimation('hands_up'),
                  child: Text("Wave"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnderContruction extends StatefulWidget {
  const UnderContruction({super.key});

  @override
  State<UnderContruction> createState() => _UnderContructionState();
}

class _UnderContructionState extends State<UnderContruction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(backgroundColor: Color(0xFFF7F7F7)),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: RiveAnimation.asset(
              //'assets/login_no_bg.riv',
              //'assets/earth_loading.riv',
              'assets/404_purple.riv',
              //'assets/cat_loading.riv',
              stateMachines: [
                // 'Loading Final - State Machine 1', //the name of the animation displayed at the top.
                //'Cat playing animation - State Machine 1',
                'SM_ComingSoon',
              ], // Add the state machine name
              // stateMachines: ['State Machine 1'],
              onInit: (Artboard artboard) {
                var controller = StateMachineController.fromArtboard(
                  artboard,
                  'SM_ComingSoon', // Make sure this matches exactly as seen in Rive
                  // 'State Machine 1',
                  //'look_idle',
                  //'Cat playing animation', // the name of the animation displayed at the left bottom.
                );
                if (controller != null) {
                  artboard.addController(controller);
                  controller.isActive = true;
                }
              },
            ),
          ),
          Expanded(
            // This ensures the text gets space
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Hi, the page you are looking for might be under construction!",
                style: GoogleFonts.openSans(
                  color: Colors.black,
                  height: 1.5,
                  fontSize: 18,
                  //fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
