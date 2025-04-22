import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puc/components/button.dart';
import 'package:puc/components/my_button.dart';
import 'package:puc/components/mytextfieldicon.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/screens/forget_password.dart';
import 'package:puc/screens/singup_screen.dart';
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
  bool isLoading = false;

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
    setState(() {
      isLoading = true;
    });

    var dio = Dio();
    dio.options.baseUrl = kAPIBaseURL;
    dio.options.connectTimeout = const Duration(milliseconds: 8000);
    dio.options.receiveTimeout = const Duration(milliseconds: 8000);
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    String url = '/auth/login';
    final payload = {
      "phone": mobileController.text,
      "password": passwordController.text,
    };

    try {
      final response = await dio.post(url, data: payload);

      if (response.data["status"]) {
        final data = response.data["data"];
        glbMemName = data["first_name"] + " " + data["last_name"];
        glbID = data["_id"];
        glbMobNo = data["phone"];
        glbEmail = data["email"];
        glbCity = data["city"];
        glbState = data["state"];
        glbPwd = passwordController.text;
        glbAuthToken = response.data["token"];

        SharedPrefData(
          userMobile: mobileController.text,
          userPWD: passwordController.text,
        ).setUserData();

        Navigator.pop(context);
        Navigator.pushNamed(context, Dashboard.id);
      } else {
        myLogoAlert(
          message: 'Something went wrong, Please try again later',
          context: context,
          navigateEnabled: false,
          route: '',
        );
      }
    } catch (e) {
      myLogoAlert(
        message: 'Something went wrong, Please try again later',
        context: context,
        navigateEnabled: false,
        route: '',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        body: Stack(
          children: [
            Center(
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
                          const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.05),
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
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: kColorWhite),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
