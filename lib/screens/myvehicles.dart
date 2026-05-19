import 'package:flutter/material.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/utils/api_helper.dart';
import 'package:puc/utils/api_urls.dart';
import 'package:puc/utils/constants.dart';
import 'package:puc/utils/mylogoalert.dart';
import '../components/drawer.dart';

class Myvehicles extends StatefulWidget {
  const Myvehicles({super.key});
  static const id = 'vehicle';

  @override
  State<Myvehicles> createState() => _MyvehiclesState();
}

class _MyvehiclesState extends State<Myvehicles> {
  bool isLoading = true;
  List<dynamic> vehicles = [];

  @override
  void initState() {
    super.initState();
    importpuc();
  }

  void importpuc() async {
    final response = await ApiHelper.get(
      context,
      ApiUrls.getPuc(glbID),
      showLoader: false,
    );

    if (response != null && response.data["status"] == true) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: kColorWhite,
        appBar: AppBar(
          backgroundColor: kColorMidNightBlue,
          title: const Text(
            'My Vehicles',
            style: TextStyle(
              fontSize: 22,
              color: kColorWhite,
              decoration: TextDecoration.none,
            ),
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
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const NewDrawer(),
        body: Stack(
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: kColorMidNightBlue,
                ),
              )
            else
              Column(
                children: [
                  vehicles.isNotEmpty
                      ? Expanded(
                    child: ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        var vehicle = vehicles[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Card(
                            margin: const EdgeInsets.all(5),
                            elevation: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Vehcile Name: ${vehicle["vehicle_name"]}', style: kListNameStyle),
                                        Text('Vehicle Type: ${vehicle["vehicle_type"]}', style: kListNameStyles),
                                        Text('Vehcile Model: ${vehicle["vehicle_model"]}', style: kListNameStyles),
                                        Text('RC Number: ${vehicle["rc"]}', style: kListNameStyles),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: kColorWhite,
                                    child: ClipOval(
                                      child: (vehicle["vehicle_front_ph"] != null &&
                                          vehicle["vehicle_front_ph"].isNotEmpty)
                                          ? Image.network(
                                        vehicle["vehicle_front_ph"],
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 30,
                                          );
                                        },
                                      )
                                          : const Icon(
                                        Icons.car_repair,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Text(
                      'No record found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
