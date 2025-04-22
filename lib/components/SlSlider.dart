import 'package:flutter/material.dart';

class SLSlider extends StatelessWidget {
  final double containerWidth = 200.0;
  final double containerHeight = 15.0;

  const SLSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the Column scrollable if the content exceeds space
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 160.0, // Fixed height for the slider
                  width: double.infinity,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
