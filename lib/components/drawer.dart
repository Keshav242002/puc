import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:puc/screens/applypucform.dart';
import 'package:puc/screens/contactus.dart';
import 'package:puc/screens/mydownloads.dart';
import 'package:puc/screens/myvehicles.dart';
import 'package:puc/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/login_screen.dart';

class NewDrawer extends StatelessWidget {
  const NewDrawer({super.key});



  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[

          Center(

            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: kColorMidNightBlue,
              ),

              accountName: Text(
                glbMemName,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                glbMobNo,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                radius: 30.0,
                backgroundImage: AssetImage('images/biglogo.jpg'),
              ),
            ),
          ),

          DrawerTile(
            title: 'My Profile',
            leading: const Icon(
              Icons.account_circle,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.of(context).pop();
             // Navigator.pushNamed(context, MyProfile.id);
            },
          ),
          DrawerTile(
            title: 'Apply For Pollution Certificate',
            leading: const Icon(
              FontAwesomeIcons.addressCard,
              color: Colors.orange,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, ApplyPUC.id);

            },
          ),
          DrawerTile(
            title: 'Insurance(Coming Soon)',
            leading: const Icon(
              Icons.shield_outlined,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
             // Navigator.pushNamed(context, Events.id);

            },
          ),
          DrawerTile(
            title: 'Loans(Coming Soon)',
            leading: const Icon(
              Icons.currency_rupee,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              //Navigator.pushNamed(context, Subscriptions.id);

            },
          ),
          DrawerTile(
            title: 'My Vehicles',
            leading: const Icon(
              Icons.car_rental,
              color: Colors.teal,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, Myvehicles.id);

            },
          ),
          DrawerTile(
            title: 'Downloads',
            leading: const Icon(
              Icons.download,
              color: Colors.indigo,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, MyDownloads.id);

            },
          ),
          DrawerTile(
            title: 'About Us',
            leading: Icon(
              Icons.info,
              color: Colors.grey[800],
            ),
            onPressed: () async {
              const url = 'https://pucindia.com/#about';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                // Handle error if the URL can't be launched
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch About Us page')),
                );
              }
            },
          ),
          DrawerTile(
            title: 'Contact Us',
            leading: const Icon(
              Icons.phone,
              color: Colors.blueGrey,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, Contact.id);
            },
          ),


          DrawerTile(
            title: 'Log Out',
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            onPressed: () async {



              
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, LoginScreen.id, (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  DrawerTile({
    required this.title,
    required this.leading,
    required this.onPressed
  });

  final String title;
  final Icon leading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      leading: leading,
      // trailing: Icon(
      //   Icons.arrow_right,
      //   size: 24.0,
      //   color: Colors.black87,
      // ),
      onTap: onPressed,
    );
  }
}
