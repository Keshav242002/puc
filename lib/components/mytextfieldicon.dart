import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

// ignore: camel_case_types
class MyTextFieldWhite extends StatelessWidget {
  final Icon displayIcon;
  final String displayLabel;
  final Function(String) onChanged;
  final bool isLast;
  final bool isNumber;
  final bool isPassword;
  final TextEditingController controller;
  final TextStyle? labelTextStyle;

  const MyTextFieldWhite({
    super.key,
    required this.displayIcon,
    required this.isPassword,
    required this.controller,
    required this.isNumber,
    required this.isLast,
    required this.displayLabel,
    required this.onChanged,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        cursorColor: kColorBase,
        decoration: InputDecoration(
          prefixIcon: displayIcon,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kColorMidNightBlue,width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kColorMidNightBlue,width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: displayLabel,
          labelStyle: labelTextStyle ?? const TextStyle(color: Colors.blueGrey),
        ),
        onChanged: onChanged,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        controller: controller,
        onSubmitted: (_) => isLast
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).nextFocus(),
      ),
    );
  }
}
