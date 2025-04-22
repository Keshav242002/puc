import 'package:flutter/material.dart';
import 'package:puc/components/drawer.dart';
import 'package:puc/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});
  static const id = 'contact';

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kColorMidNightBlue,
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 28,
            color: kColorWhite,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: NewDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40), // Top spacing
          Align(
            alignment: Alignment.center, // Center alignment
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), // Padding from sides
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(15), // Inner padding
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(color: kColorMidNightBlue, width: 2), // Blue border
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Connect with our team by clicking:",
                      style: TextStyle(
                        fontSize: 16,
                        color: kColorBase,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5), // Space between lines
                    GestureDetector(
                      onTap: () async {
                        final Uri phoneUri = Uri(scheme: 'tel', path: '+917417808994');
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          print("Could not launch $phoneUri");
                        }
                      },
                      child: const Text(
                        "+917417808994",
                        style: TextStyle(
                          fontSize: 16,
                          color: kColorBase,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, // Underline for phone number only
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "or",
                      style: TextStyle(
                        fontSize: 16,
                        color: kColorBase,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),// Space between lines
                    const Text(
                      " Feel free to reach us at ",
                      style: TextStyle(
                        fontSize: 16,
                        color: kColorBase,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      "pucindia13@gmail.com",
                      style: TextStyle(
                        fontSize: 16,
                        color: kColorBase,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
