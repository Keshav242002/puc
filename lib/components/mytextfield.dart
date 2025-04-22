import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

// ignore: camel_case_types
class MyTextField extends StatelessWidget {
  final Icon displayIcon;
  final String displayLabel;
  final Function(String) onChanged;
  final bool isLast;
  final bool isNumber;
  final bool isPassword;
  final TextEditingController controller;
  final TextStyle? labelTextStyle;

  const MyTextField({
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
        style: const TextStyle(color: Colors.black), // Black text for contrast with white background
        cursorColor: kColorBase, // Custom cursor color
        decoration: InputDecoration(
          prefixIcon: displayIcon,
          filled: true, // This makes the field filled
          fillColor: Colors.white, // White background color
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kgreen,width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kgreen,width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: displayLabel,
          labelStyle: labelTextStyle ?? const TextStyle(color: Colors.blueGrey), // Default label style
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding to change height
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
