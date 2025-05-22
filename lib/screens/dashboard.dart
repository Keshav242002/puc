import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:puc/components/drawer.dart';
import 'package:puc/screens/myprofile.dart';
import 'package:puc/utils/constants.dart';
import 'applypucform.dart';

class Dashboard extends StatefulWidget {
  static const id = "dashboard";
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  double bannerHeight = 0;
  List displayBanner = [];
  bool isLoading = true;
  double height=0;

  @override
  void initState() {
    super.initState();
    _importBanners();
  }


  Future<void> _importBanners() async {
    var dio = Dio();
    dio.options.baseUrl = kAPIBaseURL;
    dio.options.connectTimeout = const Duration(milliseconds: 5000);
    dio.options.receiveTimeout = const Duration(milliseconds: 5000);
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.options.headers["Authorization"] = "Bearer $glbAuthToken";

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    String url = '/dashboard';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data["data"] as List;
        setState(() {
          displayBanner = data.map((banner) => banner["banner"] as String).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading banners: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    bannerHeight = (screenHeight / 4 - 50);
    height = (MediaQuery.of(context).size.height / 3) / 2;

    return Scaffold(
        backgroundColor: kColorWhite,
        appBar: AppBar(
          backgroundColor: kColorMidNightBlue,
          title: const Text(
            'PUC India',
            style: TextStyle(
              fontSize: 28,
              color: kColorWhite,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer:  NewDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              isLoading
                  ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Center(
                    child: Text(
                      "No banners to display.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
                  : CarouselSlider(
                options: CarouselOptions(
                  height: bannerHeight,
                  viewportFraction: 1,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
                items: displayBanner.isNotEmpty
                    ? displayBanner
                    .map(
                      (item) => SizedBox(
                    width: double.infinity,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(2.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                          width: 800.0,
                          height: bannerHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                "Failed to load image",
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
                    .toList()
                    : [
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(2.0),
                      child: const Center(
                        child: Text(
                          "No banners available.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                    const SizedBox(
                      height: 30,
                    ),
      
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
      
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0),
                                    ),
                                    color: Colors.grey.shade300,
                                    border: Border.all(color: kColorBase),
                                  ),
                                  child: const Column(
      
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
      
                                      Icon(
                                        FontAwesomeIcons.user,
                                        size: 30,
                                        color: kColorMidNightBlue,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'My Profile',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18, color: kColorMidNightBlue,fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushNamed(context, MyProfile.id);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0),
                                    ),
                                    color: Colors.grey.shade300,
                                    border: Border.all(color: kColorBase),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.solidAddressCard,
                                        size: 30,
                                        color: kColorMidNightBlue,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Apply for\nPollution Certificate',
                                          style: TextStyle(fontSize: 18, color: kColorMidNightBlue,fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushNamed(context, ApplyPUC.id);
                                },
                              ),
                            ),
                          ),
      
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
      
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0),
                                    ),
                                    color: Colors.grey.shade300,
                                    border: Border.all(color: kColorBase),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shield_outlined,
                                        size: 30,
                                        color: kColorMidNightBlue,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Insurance\n(Coming Soon)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18, color: kColorMidNightBlue,fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                              
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0),
                                    ),
                                    color: Colors.grey.shade300,
                                    border: Border.all(color: kColorBase),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.currency_rupee,
                                        size: 30,
                                        color: kColorMidNightBlue,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          'Loans\n(Coming Soon)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18, color: kColorMidNightBlue,fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {


                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                    ),
                    const Hero(
                      tag: 'logo',
                      child: SizedBox(
                        height: 130,
                        child: Image(
                          image: AssetImage('images/logo.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

      
            ],
                ),
              ),
      bottomNavigationBar: BottomAppBar(
        color: kColorMidNightBlue.withOpacity(0.5),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright,
                size: 12,
                color: Colors.white,
              ),
              SizedBox(width: 3),
              Text(
                "PUC India All Rights Reserved|Powered by Avik Technologies",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),



    );

  }
}
