import 'package:ecommerce_provider/screens/shared/under_contruction.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,

                  ///ckgroundImage: NetworkImage(userProfilePicUrl), // Load from backend
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
              'Krithiga Perumal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'krithi25@gmail.com',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Card(
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
                      onTap: () {}, // Navigate to address management
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
                IconButton(onPressed: () {}, icon: Icon((Icons.phone))),
                IconButton(onPressed: () {}, icon: Icon((Icons.phone))),
                IconButton(onPressed: () {}, icon: Icon((Icons.phone))),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {}, // Logout
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
