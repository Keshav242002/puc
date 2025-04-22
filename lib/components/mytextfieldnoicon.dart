import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MyTextFieldNoIcon extends StatelessWidget {
  final String displayLabel;
  final Function(String) onChanged;
  final bool isLast;
  final bool isNumber;
  final bool isPassword;
  final TextEditingController controller;

  const MyTextFieldNoIcon({
    super.key,
    required this.isPassword,
    required this.controller,
    required this.isNumber,
    required this.isLast,
    required this.displayLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
      child: TextField(
        style: const TextStyle(color: kLogoBlue),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0), // Adjust padding
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kColorBase),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kColorBase),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          labelText: displayLabel,
          labelStyle: const TextStyle(color: kColorBase),
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
