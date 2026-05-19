import 'package:flutter/material.dart';

const String kAPIBaseURL = 'https://pucindia.com';



String glbAuthToken = '';
String glbToken = '';
String glbID = ''; //registration id
String glbEmail = ''; // email
String glbCity = '';
String glbState = '';
String glbCountry = '';
String glbPinCode = '';
String glbProfilePic = '';
String glbPassword = '';
String glbUserId = '';

String glbCompany = '';
String glbType = '1';
String glbCustomerId = '';
String glbDesignation = '';
String glbServer='';
String glbMobNo='';
String glbMemName='';
String glbPwd='';
String glbMemCode='';

bool glbDevice = false;


const LinearGradient kYellowPurpleGradient = LinearGradient(
  colors: [kyellow, kpurple],
  begin: Alignment.bottomRight,
  end: Alignment.topRight,
);



const kListNameStyle =
TextStyle(fontSize: 18.0, color: kColorBase, fontWeight: FontWeight.bold);
const kListNameStyles =
TextStyle(fontSize: 16.0, color: kColorBase, );

const kHeadingStyle =
TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: kColorMidNightBlue);

const kTextFieldStyle =
TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: kColorMidNightBlue);

const kListNumberStyle = TextStyle(
  fontSize: 12.0,
  color: kColorText,
);

const kPostDetailsStyle = TextStyle(
  fontSize: 10.0,
  color: kColorText,
);

const kCardStyle = TextStyle(
  fontSize: 14.0,
  color: kColorBlue,
);

const kColorText = Color(0xFF90A4AE);
const kColorBlue = Color(0xFF1E88E5);
const kColorGreen = Color(0xFF43A047);
const kColorRed = Color(0xFFDC1817);
const kColorBase = Color(0xFF1B1B1F);
const kColorWhite = Color(0xFFFFFFFF);
const kColorGrey = Color(0xFF727277);
const kColorBrown = Color(0xFF46291E);
const kColorOrange = Color(0xFFDE8661);
const kColorAmber = Color(0xFFFFC107);
const kLogoBlue = Color(0xFF052348);
const kColorMidNightBlue=Color(0xFF002E6E);

const kpurple=Color(0xFF52285a);
const kGreenB = Color(0x994CE4B1);
const kyellow=Color(0xFFFFF5C0);
const kgreenWithOpacity = Color(0x994CE4B1);
const kgreen=Color(0xFF4CE4B1);
const kdarkgrey=Color(0xFF8D8D8D);



const kDialogStyle = TextStyle(
  fontSize: 12.0,
  color: kColorGrey,
);

const kDBTextStyle = TextStyle(
    fontSize: 13,
    //color: Color(0xFF3F51B5),
    color: kColorBase);

const kAlertTextStyle = TextStyle(
    fontSize: 13,
    //color: Color(0xFF3F51B5),
    color: Colors.black);

class Constants {
  Constants._();
  static const double padding = 10;
  static const double avatarRadius = 35;
}
