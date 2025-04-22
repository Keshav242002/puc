import 'package:flutter/material.dart';
import 'package:puc/screens/applypucform.dart';
import 'package:puc/screens/contactus.dart';
import 'package:puc/screens/forget_password.dart';
import 'package:puc/screens/login_screen.dart';
import 'package:puc/screens/mydownloads.dart';
import 'package:puc/screens/myprofile.dart';
import 'package:puc/screens/myvehicles.dart';
import 'package:puc/screens/singup_screen.dart';
import 'package:puc/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/dashboard.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PUC India',
      initialRoute: SplashScreen.id,
      routes:
      {
        SplashScreen.id: (context) => const SplashScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        SignupScreen.id: (context) => const SignupScreen(),
        ForgotPassword.id: (context) => const ForgotPassword(),
        Dashboard.id: (context) =>  Dashboard(),
        ApplyPUC.id: (context) =>   ApplyPUC(),
        MyProfile.id:(context) => MyProfile(),
        Myvehicles.id:(context) => Myvehicles(),
        MyDownloads.id:(context) => MyDownloads(),
          Contact.id:(context) => Contact(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
