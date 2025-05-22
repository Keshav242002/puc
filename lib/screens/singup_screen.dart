import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:puc/components/button.dart';
import 'package:puc/components/my_button.dart';
import 'package:puc/components/mytextfield.dart';
import 'package:puc/components/mytextfieldicon.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/screens/login_screen.dart';
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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isLoading = false;
  String? _verificationId;

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
        passwordController.text.trim().isNotEmpty;
  }

  Future<void> _signup() async {
    if (mounted) setState(() => isLoading = true);

    try {
      var dio = Dio();
      dio.options.baseUrl = kAPIBaseURL;
      dio.options.connectTimeout = const Duration(milliseconds: 5000);
      dio.options.receiveTimeout = const Duration(milliseconds: 5000);
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };

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

      final response = await dio.post('/auth/signup', data: payload);

      if (response.data["status"] == true) {
        final data = response.data["data"];
        glbMemName = data["first_name"] + " " + data["last_name"];
        glbID = data["_id"];
        glbMobNo = data["phone"];
        glbEmail = data["email"];
        glbPwd = passwordController.text;
        glbToken = response.data["token"];

        await SharedPrefData(
          userMobile: mobileController.text,
          userPWD: passwordController.text,
        ).setUserData();

        if (mounted) setState(() => isLoading = false);

        Navigator.pop(context);
        Navigator.pushNamed(context, Dashboard.id);
      } else {
        if (mounted) setState(() => isLoading = false);

        myLogoAlert(
          message: response.data["message"] ?? "Signup failed. Please try again.",
          context: context,
          navigateEnabled: false,
          route: '',
        );
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);

      String errorMessage = "Something went wrong, Please try again later";

      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          errorMessage = e.response?.data["message"] ?? errorMessage;
        }
      }

      myLogoAlert(
        message: errorMessage,
        context: context,
        navigateEnabled: false,
        route: '',
      );
    }
  }


  Future<void> _startPhoneNumberVerification(String phoneNumber) async {
    if (mounted) setState(() => isLoading = true);

    String phoneWithCountryCode = '+91$phoneNumber';
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneWithCountryCode,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _firebaseAuth.signInWithCredential(credential);
          if (mounted) setState(() => isLoading = true);
          await _signup();
        } catch (e) {
          if (mounted) setState(() => isLoading = false);
          myLogoAlert(
            context: context,
            message: "Auto verification failed. Try manually.",
            navigateEnabled: false,
            route: '',
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) setState(() => isLoading = false);
        myLogoAlert(
          context: context,
          message: e.message ?? "Phone verification failed",
          navigateEnabled: false,
          route: '',
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) setState(() {
          _verificationId = verificationId;
          isLoading = false;
        });
        _showOTPDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _showOTPDialog() {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kColorWhite,
        title: Column(
          children: const [
            Center(child: Text("Enter Verification Code", textAlign: TextAlign.center)),
            Padding(
              padding: EdgeInsets.only(top: 4.0, left: 10.0),
              child: Text('*Wait for 5 seconds to auto submit', style: kDialogStyle),
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
              if (otpController.text.isNotEmpty && _verificationId != null) {
                if (mounted) setState(() => isLoading = true);
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId!,
                  smsCode: otpController.text,
                );

                try {
                  final userCredential = await _firebaseAuth.signInWithCredential(credential);
                  if (userCredential.user != null) {
                    Navigator.pop(context); // close dialog
                    await _signup();
                  } else {
                    if (mounted) setState(() => isLoading = false);
                    myLogoAlert(
                      context: context,
                      message: "Verification failed. Try again.",
                      navigateEnabled: false,
                      route: '',
                    );
                  }
                } catch (e) {
                  if (mounted) setState(() => isLoading = false);
                  myLogoAlert(
                    context: context,
                    message: e.toString(),
                    navigateEnabled: false,
                    route: '',
                  );
                }
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
                        displayIcon: const Icon(Icons.person, color: kColorBase),
                        isPassword: false,
                        controller: firstnameController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'First Name',
                        onChanged: (value) => firstnameController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.person, color: kColorBase),
                        isPassword: false,
                        controller: lastnameController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Last Name',
                        onChanged: (value) => lastnameController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.phone, color: kColorBase),
                        isPassword: false,
                        controller: mobileController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Mobile No.',
                        onChanged: (value) => mobileController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.email, color: kColorBase),
                        isPassword: false,
                        controller: emailController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Email ID',
                        onChanged: (value) => emailController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.add_home_outlined, color: kColorBase),
                        isPassword: false,
                        controller: cityController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'City',
                        onChanged: (value) => cityController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.add_location_sharp, color: kColorBase),
                        isPassword: false,
                        controller: stateController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'State',
                        onChanged: (value) => stateController.text = value,
                      ),
                      MyTextFieldWhite(
                        displayIcon: const Icon(Icons.vpn_key, color: kColorBase),
                        isPassword: true,
                        controller: passwordController,
                        isNumber: false,
                        isLast: true,
                        displayLabel: 'Password',
                        onChanged: (value) => passwordController.text = value,
                      ),
                      const SizedBox(height: 24),

                     MyButton(
                        title: 'SignUp',
                        color: kColorMidNightBlue,
                        width: screenWidth * 0.8,
                        textColor: kColorBase,
                        onPressed: () {
                          if (_areFieldsValid()) {
                           // _signup();
                            _startPhoneNumberVerification(mobileController.text);
                          } else {
                            myLogoAlert(
                              context: context,
                              message: "Kindly Fill all the Details",
                              navigateEnabled: false,
                              route: '',
                            );
                          }
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
