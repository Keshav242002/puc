import 'package:flutter/material.dart';
import 'package:puc/components/button.dart';
import 'package:puc/components/my_button.dart';
import 'package:puc/components/mytextfield.dart';
import 'package:puc/components/mytextfieldicon.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/screens/login_screen.dart';
import 'package:puc/utils/api_helper.dart';
import 'package:puc/utils/api_urls.dart';
import 'package:puc/utils/constants.dart';
import 'package:puc/utils/mylogoalert.dart';
import 'package:puc/utils/shared_prefrences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const String id = 'signup_screen';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  bool isLoading = false;
  String? _signupUserId;

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    emailController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }

  bool _areFieldsValid() {
    return firstnameController.text.trim().isNotEmpty &&
        lastnameController.text.trim().isNotEmpty &&
        mobileController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        stateController.text.trim().isNotEmpty &&
        passwordController.text.trim().length >= 8;
  }

  Future<void> _signup() async {
    if (!_areFieldsValid()) {
      if (passwordController.text.trim().isNotEmpty &&
          passwordController.text.trim().length < 8) {
        myLogoAlert(
          context: context,
          message: "Password must be at least 8 characters",
          navigateEnabled: false,
          route: '',
        );
      } else {
        myLogoAlert(
          context: context,
          message: "Kindly Fill all the Details",
          navigateEnabled: false,
          route: '',
        );
      }
      return;
    }

    final payload = {
      "first_name": firstnameController.text,
      "last_name": lastnameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "phone": mobileController.text,
      "dob": "1",
      "city": cityController.text,
      "state": stateController.text,
    };

    final response = await ApiHelper.post(
      context,
      ApiUrls.signup,
      data: payload,
      requiresAuth: false,
    );

    if (response != null && response.data["status"] == true) {
      final data = response.data["data"];
      _signupUserId = data["id"];

      // Store controller values to globals
      glbMemName =
          "${firstnameController.text} ${lastnameController.text}";
      glbMobNo = mobileController.text;
      glbEmail = emailController.text;
      glbPwd = passwordController.text;
      glbID = data["id"] ?? '';

      print('>>> [Signup] Globals set — glbMemName: $glbMemName, glbMobNo: $glbMobNo, glbEmail: $glbEmail, glbID: $glbID');

      await SharedPrefData(
        userMobile: mobileController.text,
        userPWD: passwordController.text,
      ).setUserData();

      print('>>> [Signup] SharedPreferences saved — phone: ${mobileController.text}');

      // Show OTP dialog
      if (mounted) _showOTPDialog();
    }
  }

  Future<void> _verifyOtp(String otp) async {
    final response = await ApiHelper.post(
      context,
      ApiUrls.verifyOtp,
      data: {
        "userId": _signupUserId,
        "otp": otp,
      },
      requiresAuth: false,
    );

    if (response != null) {
      if (response.data["status"] == true) {
        glbToken = response.data["token"];
        print('>>> [VerifyOtp] glbToken set: $glbToken');

        // Also update globals from verify response data if available
        final data = response.data["data"];
        if (data != null) {
          glbMemName = "${data["first_name"]} ${data["last_name"]}";
          glbID = data["id"] ?? glbID;
          glbMobNo = data["phone"] ?? glbMobNo;
          glbEmail = data["email"] ?? glbEmail;
          print('>>> [VerifyOtp] Globals updated from response — glbMemName: $glbMemName, glbID: $glbID');
        }

        if (mounted) {
          Navigator.pop(context); // close OTP dialog
          Navigator.pop(context); // pop signup screen
          Navigator.pushNamed(context, Dashboard.id);
        }
      } else {
        // OTP verification failed — show toast with API message
        final message = response.data["message"] ?? "OTP verification failed";
        print('>>> [VerifyOtp] Failed — $message');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    }
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
              child:
                  Text('*OTP sent to your phone', style: kDialogStyle),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child:
                  Text('*OTP expires in 60 seconds', style: kDialogStyle),
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
              if (otpController.text.isNotEmpty && _signupUserId != null) {
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
      onWillPop: () async {
        Navigator.pushNamed(context, LoginScreen.id);
        return false;
      },
      child: Scaffold(
        backgroundColor: kColorWhite,
        appBar: AppBar(
          backgroundColor: kColorWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: SizedBox(
                          height: screenHeight * 0.12,
                          child: const Image(
                            image: AssetImage('images/logo.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      MyTextFieldWhite(
                        displayIcon:
                            const Icon(Icons.person, color: kColorBase),
                        isPassword: false,
                        controller: firstnameController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'First Name',
                        onChanged: (value) =>
                            firstnameController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon:
                            const Icon(Icons.person, color: kColorBase),
                        isPassword: false,
                        controller: lastnameController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Last Name',
                        onChanged: (value) =>
                            lastnameController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon:
                            const Icon(Icons.phone, color: kColorBase),
                        isPassword: false,
                        controller: mobileController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Mobile No.',
                        onChanged: (value) =>
                            mobileController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon:
                            const Icon(Icons.email, color: kColorBase),
                        isPassword: false,
                        controller: emailController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Email ID',
                        onChanged: (value) =>
                            emailController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.add_home_outlined,
                            color: kColorBase),
                        isPassword: false,
                        controller: cityController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'City',
                        onChanged: (value) =>
                            cityController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.add_location_sharp,
                            color: kColorBase),
                        isPassword: false,
                        controller: stateController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'State',
                        onChanged: (value) =>
                            stateController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon:
                            const Icon(Icons.vpn_key, color: kColorBase),
                        isPassword: true,
                        controller: passwordController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Password',
                        onChanged: (value) =>
                            passwordController.text = value,
                      ),
                      const SizedBox(height: 24),

                      MyButton(
                        title: 'SignUp',
                        color: kColorMidNightBlue,
                        width: screenWidth * 0.8,
                        textColor: kColorBase,
                        onPressed: () {
                          _signup();
                        },
                      ),
                      const SizedBox(height: 30),
                      Button(
                        title: 'Already Signed Up - Login',
                        color: kColorWhite,
                        width: screenWidth * 0.8,
                        textColor: kColorBase,
                        onPressed: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
