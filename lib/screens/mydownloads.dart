import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:puc/components/drawer.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/utils/constants.dart';
import 'package:puc/utils/mylogoalert.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDownloads extends StatefulWidget {
  const MyDownloads({super.key});
  static const id = 'downloads';

  @override
  State<MyDownloads> createState() => _MyDownloadsState();
}

class _MyDownloadsState extends State<MyDownloads> {
  bool isLoading = true;
  List<dynamic> vehicles = [];

  @override
  void initState() {
    super.initState();
    importpuclink();
  }

  void importpuclink() async {
    var dio = Dio();
    dio.options.baseUrl = kAPIBaseURL;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.interceptors.add(LogInterceptor(requestBody: false));
    dio.options.headers["Authorization"] = "Bearer $glbAuthToken";
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    String url = '/uploadpuc/$glbID';

    try {
      final response = await dio.get(url);
      if (response.data["status"] == true) {
        var data = response.data["data"];
        if (data is List) {
          setState(() {
            vehicles = data;
            isLoading = false;
          });
        } else {
          setState(() {
            vehicles = [data];
            isLoading = false;
          });
        }

        if (vehicles.isEmpty) {
          myLogoAlert(
            context: context,
            message: "No record found",
            navigateEnabled: false,
            route: '',
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        myLogoAlert(
          context: context,
          message: response.data["message"],
          navigateEnabled: false,
          route: '',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _onWillPop() async {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  Dashboard()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Downloads',
            style: TextStyle(color: kColorWhite, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, Dashboard.id);
              },
            ),
          ],
          backgroundColor: kColorMidNightBlue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const NewDrawer(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : vehicles.isEmpty
            ? const Center(child: Text('No records found.'))
            : ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage(
                    "images/biglogo.jpg",
                  ),
                ),
                title: Text(vehicle['rc']),
                subtitle: const Text("Tap to Download PUC Certificate"),
                trailing: const Icon(
                  Icons.link,
                  color: Colors.indigo,
                  size: 30,
                ),
                onTap: () {
                  final url = Uri.parse(vehicle['puclinks']);
                  _launchURL(url);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
