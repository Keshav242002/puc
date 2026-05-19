import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:puc/components/mytextfieldicon.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/utils/api_helper.dart';
import 'package:puc/utils/api_urls.dart';
import 'package:puc/utils/mylogoalert.dart';
import 'package:puc/utils/shared_prefrences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/my_button.dart';
import '../components/my_visible_indicator.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});
  static const String id = 'forgot_password';

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  double scrWidth = 0;
  String myPwd = '';
  TextEditingController uMobile = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getUserPrefData() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      uMobile.text = pref.getString('userMobile') ?? '';
      myPwd = pref.getString('userPWD') ?? '';
    });
  }

  void _loginUser() async {
    setState(() {
      isLoading = true;
    });

    final payload = {
      "phone": uMobile.text,
      "password": myPwd,
    };

    final response = await ApiHelper.post(
      context,
      ApiUrls.login,
      data: payload,
      requiresAuth: false,
      showLoader: false,
    );

    if (response != null && response.data["status"]) {
      final data = response.data["data"];
      glbMemName = data["first_name"] + " " + data["last_name"];
      glbID = data["_id"];
      glbMobNo = data["phone"];
      glbEmail = data["email"];
      glbCity = data["city"];
      glbState = data["state"];
      glbPwd = myPwd;
      glbAuthToken = response.data["token"];
      print(glbEmail);
      SharedPrefData(
        userMobile: uMobile.text,
        userPWD: myPwd,
      ).setUserData();

      Navigator.pop(context);
      Navigator.pushNamed(context, Dashboard.id);
    }

    setState(() {
      isLoading = false;
    });
  }

  bool checkFields() {
    if (uMobile.text.isEmpty) {
      return false;
    } else if (uMobile.text.length != 10) {
      myLogoAlert(
        context: context,
        message: 'Enter a 10-digit number',
        navigateEnabled: false,
        route: '',
      );
      return false;
    }
    return true;
  }

  Future<void> _retrievePassword() async {
    final payload = {
      "phone": uMobile.text,
    };

    final response = await ApiHelper.post(
      context,
      ApiUrls.forgotPassword,
      data: payload,
      requiresAuth: false,
      showLoader: false,
    );

    if (response != null && response.data["status"]) {
      final data = response.data["data"];
      myPwd = data["password"];
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _validateNumber(String phone, BuildContext context) async {
    final payload = {
      "phone": uMobile.text,
    };

    final response = await ApiHelper.post(
      context,
      ApiUrls.forgotPassword,
      data: payload,
      requiresAuth: false,
      showLoader: false,
    );

    if (response == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (response.data["status"]) {
      // Proceed with Firebase phone number verification
      final FirebaseAuth fbAuth = FirebaseAuth.instance;
      phone = '+91$phone';

      fbAuth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential authCred) {
            fbAuth.signInWithCredential(authCred).then((UserCredential result) async {
              // Retrieve password and log in
              await _retrievePassword();
              _loginUser();
              isLoading = true;
            }).catchError((e) {
              setState(() {
                isLoading = false;
                myLogoAlert(
                    context: context,
                    navigateEnabled: false,
                    route: '',
                    message: e.toString());
              });
            });
          },
          verificationFailed: (FirebaseAuthException ex) {
            setState(() {
              isLoading = false;
              myLogoAlert(
                  context: context,
                  navigateEnabled: false,
                  route: '',
                  message: ex.toString());
            });
          },
          codeSent: (String verificationId, int? forceResendingToken) {
            final code = TextEditingController();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                backgroundColor: kColorWhite,
                title: const Column(
                  children: [
                    Center(child: Text("Enter Verification Code",
                      textAlign: TextAlign.center,)),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0, left: 10.0),
                      child: Text(
                        '*Wait for 5 seconds to auto submit',
                        style: kDialogStyle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        '*OTP expires in 60 seconds',
                        style: kDialogStyle,
                      ),
                    ),
                  ],
                ),
                content: MyTextFieldWhite(
                  displayIcon: const Icon(
                    Icons.password,
                    color: Colors.blue,
                  ),
                  isPassword: false,
                  controller: code,
                  isNumber: true,
                  displayLabel: 'Enter OTP',
                  isLast: true,
                  onChanged: (val) {
                    code.text = val;
                  },
                ),
                actions: [
                  MyButton(
                    title: 'Submit',
                    color: kColorMidNightBlue,
                    onPressed: () {
                      if (code.text == '') {
                        //do nothing
                      } else {
                        var cred = PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: code.text);
                        fbAuth.signInWithCredential(cred).then((UserCredential result) async {
                          Navigator.pop(context);
                          // Retrieve password and log in
                          isLoading = true;
                          await _retrievePassword();
                          _loginUser();
                        }).catchError((e) {
                          Navigator.pop(context);
                          setState(() {
                            isLoading = false;
                            myLogoAlert(
                                context: context,
                                navigateEnabled: false,
                                route: '',
                                message: e.toString());
                          });
                        });
                      }
                    },
                    width: 100, textColor: kColorWhite,),
                ],
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
          }
      );
    } else {
      setState(() {
        isLoading = false;
        myLogoAlert(
            context: context,
            navigateEnabled: false,
            route: '',
            message: response.data["message"]);
      });
    }
  }

  void _handleCancel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {

  scrWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return false; // Prevent default back behavior
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kColorWhite,
          body: Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 150.0),
                      child: Hero(
                        tag: 'logo',
                        child: SizedBox(
                          height: 100,
                          child: Image(
                            image: AssetImage('images/logo.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    const Text(
                      'FORGOT PASSWORD',
                      style: kTextFieldStyle,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
                      child: Text(
                        'We will first validate your number',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: kColorBase),
                      ),
                    ),
                    MyTextFieldWhite(
                      displayIcon: const Icon(
                        Icons.phone,
                        color: kColorBase,
                      ),
                      isPassword: false,
                      controller: uMobile,
                      isNumber: true,
                      isLast: true,
                      displayLabel: 'Enter Phone',
                      onChanged: (value) {
                        uMobile.text = value;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MyButton(
                          title: 'Cancel',
                          color: kColorRed,
                          onPressed: _handleCancel,
                          width: 130,
                          textColor: kColorBase,
                        ),
                        MyButton(
                          title: 'Submit',
                          color: kColorMidNightBlue,
                          onPressed: () {
                            setState(() {
                              if (uMobile.text == '') {
                                myLogoAlert(
                                  context: context,
                                  navigateEnabled: false,
                                  route: '',
                                  message: 'Please enter a valid number',
                                );
                              } else {
                                if (checkFields()) {
                                  isLoading = true;
                                  // Add your validation or API logic here
                                  _validateNumber(uMobile.text, context);
                                }
                              }
                            });
                          },
                          width: 130,
                          textColor: kColorBase,
                        ),
                      ],
                    ),
                    myVisibleIndicator(isVisible: isLoading),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
