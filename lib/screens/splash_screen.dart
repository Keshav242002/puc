import 'package:flutter/material.dart';
import 'package:puc/utils/constants.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String id = 'splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToLogin();
  }

  Future<void> navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorMidNightBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 200,
              height: 200,
              child: Image(
                image: AssetImage('images/biglogo.jpg'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: kColorWhite),
            const SizedBox(height: 20),
            const Text(
              'Welcome To PUC India',
              style: kHeadingStyle,
            ),
          ],
        ),
      ),
    );
  }
}