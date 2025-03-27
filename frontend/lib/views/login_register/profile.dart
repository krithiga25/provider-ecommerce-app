import 'package:ecommerce_provider/views/login_register/login.dart';
import 'package:ecommerce_provider/views/shared/under_contruction.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.email});

  final String? email;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences prefs;

  // void initSharedPref() async {
  //   prefs = await SharedPreferences.getInstance();
  //   prefs.remove('token');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image(
                  image: AssetImage('assets/fox_profile.jpg'),
                  // height: 30,
                  width: 120,
                ),
                // Positioned(
                //   bottom: 0,
                //   right: 5,
                //   child: FloatingActionButton.small(
                //     onPressed: () {},
                //     child: Icon(Icons.edit, size: 18),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              widget.email!.split('@')[0],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.email.toString(),
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
                        Icon(Icons.settings, color: Colors.blue),
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
                    // ListTile(
                    //   leading: Icon(Icons.payment),
                    //   title: Text("Payment Methods"),
                    //   trailing: Icon(Icons.arrow_forward_ios),
                    //   onTap: () {}, // Navigate to payment methods
                    // ),
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
                        Icon(Icons.history, color: Colors.blue),
                      ],
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delivery_dining_rounded),
                      title: Text("Delivered"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        //navigate to the orders page with only the delivered data.
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text("Processing"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        //navigate to the orders page on the delivery items
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
                //prefs.remove('token');
                //widget.email = null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }, // Logout
              child: SizedBox(
                height: 60,
                child: Card(
                  elevation: 2,
                  color: Colors.redAccent,
                  child: Center(
                    child: Text(
                      "Log Out",
                      style: TextStyle(color: Colors.white),
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
}
