import 'package:flutter/material.dart';
import 'package:puc/screens/dashboard.dart';
import '../../../utils/constants.dart';
import '../components/drawer.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);
  static const String id = 'my_profile';

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  Dashboard()),
    );
    return false; // Prevents default back action
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: kColorWhite,
        appBar: AppBar(
          backgroundColor: kColorMidNightBlue,
          title: const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 22,
              color: kColorWhite,
              decoration: TextDecoration.none,
            ),
          ),

          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const NewDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ProfileListTile(
                      title: 'Name',
                      value: glbMemName,
                      icon: Icons.person,
                    ),
                    ProfileListTile(
                      title: 'Mobile',
                      value: glbMobNo,
                      icon: Icons.phone,
                    ),
                    ProfileListTile(
                      title: 'Email',
                      value: glbEmail,
                      icon: Icons.email,
                    ),
                    ProfileListTile(
                      title: 'City',
                      value: glbCity,
                      icon: Icons.location_city,
                    ),
                    ProfileListTile(
                      title: 'State',
                      value: glbState,
                      icon: Icons.map,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kColorMidNightBlue, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: kColorMidNightBlue,
            ),
            const SizedBox(width: 12), // Space between icon and text
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: '$title: ', // Title with colon
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: value, // Value immediately after colon
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
