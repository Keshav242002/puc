import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefData {
  String userMobile;
  String userPWD;

  SharedPrefData({
    required this.userMobile,
    required this.userPWD,
  });

  Future<String> setUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (userMobile != '') {
      pref.setString('userMobile', userMobile);
    }

    if (userPWD != '') {
      pref.setString('userPWD', userPWD);
    }

    return 'saved';
  }
}
