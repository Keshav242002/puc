import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:puc/screens/login_screen.dart';
import 'package:puc/utils/constants.dart';
import 'package:puc/utils/mylogoalert.dart';
import 'package:puc/utils/shared_prefrences.dart';
import 'package:shared_preferences/shared_preferences.dart';



class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {

  TextEditingController _pwdController = TextEditingController();



  getUserPrefData() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _pwdController.text = pref.getString('userPWD')!;
    });
  }

  void updatePassword() async {
    var dio = Dio();
    dio.options.baseUrl = kAPIBaseURL;
    dio.options.connectTimeout = const Duration(milliseconds: 5000);
    dio.options.receiveTimeout = const Duration(milliseconds: 5000);
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.options.headers["Authorization"] = "Bearer $glbAuthToken";

    FormData formData = FormData.fromMap({
      'id': glbID,
      'password': _pwdController.text,
    });

    try {
      var response = await dio.post('changepassword.php', data: formData);
      if (response.data["status"]) {
        setState(() {
          glbPwd = _pwdController.text;
          SharedPrefData(
            userMobile: glbMobNo,
            userPWD: _pwdController.text,
          ).setUserData();
        });

        myLogoAlert(
          context: context,
          message: 'Password updated successfully',
          navigateEnabled: false,
          route: '',
        );
      } else {
        myLogoAlert(
          context: context,
          message: response.data["message"],
          navigateEnabled: false,
          route: '',
        );
      }
    } catch (e) {
      myLogoAlert(
        context: context,
        message: 'Failed to update password',
        navigateEnabled: false,
        route: '',
      );
    }
  }

  void showPasswordEdit(BuildContext context) {
    _pwdController.text = glbPwd;
    bool _isPasswordVisible = false;

    AlertDialog alert = AlertDialog(
      title: const Text('Change Password'),
      content: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextField(
              controller: _pwdController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Enter New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: (val) {
                _pwdController.text = val;
              },
            );
          },
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kyellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Adjust roundedness here
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: kgreen, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10), // Add space between buttons
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kgreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Adjust roundedness here
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  updatePassword();
                },
                child: const Text(
                  'Set New',
                  style: TextStyle(color: kyellow, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: kGreenB,
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.05, left: screenWidth * 0.1, bottom: screenHeight * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row for Image and glbMemName
                Row(
                  children: <Widget>[
                    // CircleAvatar(
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    //     child: const Image(
                    //       fit: BoxFit.cover,
                    //       image: AssetImage('images/LOGO.png'),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: screenWidth * 0.02,
                    // ),
                    Text(
                      '$glbMemName',
                      style: TextStyle(
                        color: kColorWhite,
                        fontSize: screenHeight * 0.023,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Column for glbEmail and glbMobNo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$glbEmail',
                      style: TextStyle(
                        color:kColorWhite,
                        fontSize: screenHeight * 0.017,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$glbMobNo',
                      style: TextStyle(
                        color: kColorWhite,
                        fontSize: screenHeight * 0.017,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    print("My vehicles");
                  },
                  child: NewRow(
                    text: 'My vehicles',
                    icon: FontAwesomeIcons.automobile,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                GestureDetector(
                  onTap: () {
                    print("Feedback tapped");
                  },
                  child: NewRow(
                    text: 'Downloads',
                    icon: Icons.download,
                    fontSize: screenHeight * 0.02,
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.02,
                ),
                GestureDetector(
                  onTap: () {
                    showPasswordEdit(context);
                  },
                  child: NewRow(
                    text: 'Change Password',
                    icon: Icons.password,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
              

              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, LoginScreen.id, (Route<dynamic> route) => false);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.exit_to_app,
                    color: kColorWhite.withOpacity(0.5),
                    size: screenHeight * 0.03,
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Text(
                    'Log out',
                    style: TextStyle(
                      color: kColorWhite.withOpacity(0.5),
                      fontSize: screenHeight * 0.025,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double fontSize;

  const NewRow({
    Key? key,
    required this.icon,
    required this.text,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: kyellow,
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          text,
          style: TextStyle(
            color: kColorWhite,
            fontSize: fontSize,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
