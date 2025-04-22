import 'package:flutter/material.dart';

import '../utils/constants.dart';

class NewButton extends StatelessWidget {
  const NewButton({
    required this.title,
    required this.color,
    required this.onPressed,
    required this.width,
    required this.textColor,
    this.borderColor = kColorWhite, // Optional border color, default to transparent
  });

  final Color color;
  final String title;
  final Function onPressed;
  final double width;
  final Color textColor;
  final Color borderColor; // New border color property

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(height: 40, width: width),
        child: ElevatedButton(
          onPressed: () {
            return onPressed();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(color),
            elevation: MaterialStateProperty.all<double>(0), // Removed elevation
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: borderColor, width: 1), // Border color and width
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
