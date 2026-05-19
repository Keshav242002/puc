import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:puc/components/button.dart';
import 'package:puc/components/my_button.dart';
import 'package:puc/components/mytextfield.dart';
import 'package:puc/components/mytextfieldicon.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/screens/forget_password.dart';
import 'package:puc/screens/signup_screen.dart';
import 'package:puc/utils/api_helper.dart';
import 'package:puc/utils/api_urls.dart';
import 'package:puc/utils/constants.dart';
import 'package:puc/utils/mylogoalert.dart';
import 'package:puc/utils/shared_prefrences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/newbutton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _loginUserId;

  @override
  void initState() {
    super.initState();
    getUserPrefData();
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return false;
  }

  Future<void> getUserPrefData() async {
    final pref = await SharedPreferences.getInstance();
    String? storedMobile = pref.getString('userMobile');
    String? storedPWD = pref.getString('userPWD');

    if (storedMobile != null && storedPWD != null) {
      setState(() {
        mobileController.text = storedMobile;
        passwordController.text = storedPWD;
      });
    }
  }

  bool get _areFieldsValid {
    return mobileController.text.trim().length == 10 &&
        passwordController.text.trim().isNotEmpty;
  }

  void _loginUser() async {
    final payload = {
      "phone": mobileController.text,
      "password": passwordController.text,
    };

    final response = await ApiHelper.post(
      context,
      ApiUrls.login,
      data: payload,
      requiresAuth: false,
    );

    if (response != null && response.data["status"] == true) {
      final data = response.data["data"];

      // Check if OTP verification is required
      if (data["sendOtp"] == true) {
        _loginUserId = data["id"];
        print('>>> [Login] OTP required — userId: $_loginUserId');

        // Save credentials to SharedPreferences
        SharedPrefData(
          userMobile: mobileController.text,
          userPWD: passwordController.text,
        ).setUserData();

        if (mounted) _showOTPDialog();
      } else {
        // Direct login (no OTP) — fallback if API changes back
        glbMemName = (data["first_name"] ?? "") + " " + (data["last_name"] ?? "");
        glbID = data["_id"] ?? data["id"] ?? '';
        glbMobNo = data["phone"] ?? '';
        glbEmail = data["email"] ?? '';
        glbCity = data["city"] ?? '';
        glbState = data["state"] ?? '';
        glbPwd = passwordController.text;
        glbAuthToken = response.data["token"] ?? '';

        SharedPrefData(
          userMobile: mobileController.text,
          userPWD: passwordController.text,
        ).setUserData();

        Navigator.pop(context);
        Navigator.pushNamed(context, Dashboard.id);
      }
    }
  }

  Future<void> _verifyOtp(String otp) async {
    final response = await ApiHelper.post(
      context,
      ApiUrls.verifyOtp,
      data: {
        "userId": _loginUserId,
        "otp": otp,
      },
      requiresAuth: false,
    );

    if (response != null) {
      if (response.data["status"] == true) {
        glbToken = response.data["token"] ?? '';
        glbAuthToken = response.data["token"] ?? '';
        print('>>> [Login VerifyOtp] glbToken set: $glbToken');

        final data = response.data["data"];
        if (data != null) {
          glbMemName = "${data["first_name"]} ${data["last_name"]}";
          glbID = data["id"] ?? data["_id"] ?? '';
          glbMobNo = data["phone"] ?? '';
          glbEmail = data["email"] ?? '';
          glbCity = data["city"] ?? '';
          glbState = data["state"] ?? '';
          print('>>> [Login VerifyOtp] Globals updated — glbMemName: $glbMemName, glbID: $glbID');
        }

        glbPwd = passwordController.text;

        SharedPrefData(
          userMobile: mobileController.text,
          userPWD: passwordController.text,
        ).setUserData();

        if (mounted) {
          Navigator.pop(context); // close OTP dialog
          Navigator.pop(context); // pop login screen
          Navigator.pushNamed(context, Dashboard.id);
        }
      } else {
        final message = response.data["message"] ?? "OTP verification failed";
        print('>>> [Login VerifyOtp] Failed — $message');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    }
  }

  void _showContactUsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: kColorWhite,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kColorBase,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Raise an issue',
                style: TextStyle(fontSize: 14, color: kColorGrey),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call, color: kColorMidNightBlue),
              title: const Text('Call 7451965755'),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('tel:7451965755');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.green.shade600),
              title: const Text('Connect on WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('https://wa.me/917451965755');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOTPDialog() {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kColorWhite,
        title: Column(
          children: const [
            Center(
                child: Text("Enter Verification Code",
                    textAlign: TextAlign.center)),
            Padding(
              padding: EdgeInsets.only(top: 4.0, left: 10.0),
              child: Text('*OTP sent to your phone', style: kDialogStyle),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text('*OTP expires in 60 seconds', style: kDialogStyle),
            ),
          ],
        ),
        content: MyTextField(
          displayIcon: const Icon(Icons.password, color: kColorMidNightBlue),
          isPassword: false,
          controller: otpController,
          isNumber: true,
          displayLabel: 'Enter OTP',
          isLast: true,
          onChanged: (val) {},
        ),
        actions: [
          MyButton(
            title: 'Submit',
            color: kColorMidNightBlue,
            onPressed: () async {
              if (otpController.text.isNotEmpty && _loginUserId != null) {
                await _verifyOtp(otpController.text);
              }
            },
            width: 100,
            textColor: kyellow,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: kColorWhite,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: kColorWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: SizedBox(
                          height: screenHeight * 0.15,
                          child: const Image(
                            image: AssetImage('images/logo.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.phone, color: kColorBase),
                        isPassword: false,
                        controller: mobileController,
                        isNumber: true,
                        isLast: false,
                        displayLabel: 'Mobile No.',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.vpn_key, color: kColorBase),
                        isPassword: true,
                        controller: passwordController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Password',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      MyButton(
                        title: 'Login',
                        color: _areFieldsValid ? kColorMidNightBlue : Colors.grey,
                        onPressed: _areFieldsValid
                            ? () => _loginUser()
                            : () {
                          myLogoAlert(
                            context: context,
                            message: 'Please enter valid credentials',
                            navigateEnabled: false,
                            route: '',
                          );
                        },
                        width: screenWidth * 0.8,
                        textColor: kColorBase,
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                        child: NewButton(
                          title: 'Forget Password',
                          color: kColorWhite,
                          width: screenWidth * 0.8,
                          textColor: kColorMidNightBlue,
                          onPressed: () {
                            Navigator.pushNamed(context, ForgotPassword.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Button(
                    title: 'New Registration - Sign Up',
                    color: kColorWhite,
                    width: screenWidth * 0.8,
                    textColor: kColorBase,
                    onPressed: () {
                      Navigator.pushNamed(context, SignupScreen.id);
                    },
                  ),
                ),
                NewButton(
                  title: 'Contact Us',
                  color: kColorWhite,
                  width: screenWidth * 0.8,
                  textColor: kColorMidNightBlue,
                  onPressed: () => _showContactUsSheet(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
