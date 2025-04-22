import 'package:flutter/material.dart';
import 'package:puc/utils/constants.dart';



// ignore: camel_case_types
class myVisibleIndicator extends StatelessWidget {
  const myVisibleIndicator({Key? key, required this.isVisible})
      : super(key: key);

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kColorMidNightBlue),
          ),
        ),
      ),
    );
  }
}
