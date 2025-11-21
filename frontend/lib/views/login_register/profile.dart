import 'package:ecommerce_provider/views/login_register/login.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:ecommerce_provider/views/shared/under_contruction.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences prefs;
  String? email;
  bool isLoading = true;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('currentuser');
  }

  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('currentuser') ?? '';
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (email == null || email!.isEmpty) {
      return Scaffold(body: Center(child: Text("No user logged in")));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image(image: AssetImage('assets/fox_profile.jpg'), width: 120),
              ],
            ),
            SizedBox(height: 10),
            Text(
              email!.split('@')[0],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              email.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Account Settings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.settings, color: Colors.black),
                      ],
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text("Manage Addresses"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnderContruction(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.light_mode),
                      title: Text("Switch Themes"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnderContruction(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order Details",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.history, color: Colors.black),
                      ],
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delivery_dining_rounded),
                      title: Text("Delivered"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => NavigationExample(initialIndex: 3),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text("Processing"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => NavigationExample(initialIndex: 3),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'CONTACT US',
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.phone)),
                IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/mailWhite.png',
                    width: 30,
                    height: 30,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/instaWhite.png',
                    width: 30,
                    height: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _logOutConfirmationDialog();
              },
              child: SizedBox(
                height: 60,
                child: Card(
                  elevation: 2,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      "LOG OUT",
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _logOutConfirmationDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF7F7F7),

          title: Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 20),
            child: Text(
              "Are you sure you want to log out?",
              style: GoogleFonts.openSans(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                color: Colors.black,
                height: 40,
                width: 100,
                child: TextButton(
                  child: Text(
                    "LOG OUT",
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    initSharedPref();
                    Navigator.of(context).pop();
                    Future.delayed(Duration(seconds: 3));
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
            TextButton(
              child: Text(
                "CANCEL",
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
