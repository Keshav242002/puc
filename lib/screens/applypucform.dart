import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io' as io;
import 'package:puc/components/mytextfieldnoicon.dart';
import 'package:puc/screens/dashboard.dart';
import 'package:puc/utils/api_helper.dart';
import 'package:puc/utils/api_urls.dart';
import 'package:puc/utils/mylogoalert.dart';
import '../components/drawer.dart';
import '../utils/constants.dart';
import 'package:http_parser/http_parser.dart';

class ApplyPUC extends StatefulWidget {
  const ApplyPUC({super.key});
  static const id = "puc";

  @override
  State<ApplyPUC> createState() => _ApplyPUCState();
}

class _ApplyPUCState extends State<ApplyPUC> {
  String? selectedVehicleType;
  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  File? frontImage;
  File? rearImage;
  bool isLoading = false;
  String orderId='';
  String paymentSessionId='';
  String cfOrderId='';
  String pucID='';


  final ImagePicker _picker = ImagePicker();
  int pucAmount = 0;

  void _updatePucAmount(String? vehicleType) {
    setState(() {
      if (vehicleType == 'Bike') {
        pucAmount = 65;
      } else if (vehicleType == 'Car Petrol') {
        pucAmount = 85;
      } else if (vehicleType == 'Car Diesel') {
        pucAmount = 115;
      } else {
        pucAmount = 0;
      }
      print("PUC Amount: $pucAmount");
    });
  }

  @override
  void dispose() {
    vehicleNameController.dispose();
    vehicleNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCompressImage(ImageSource source, bool isFrontImage) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        '${io.Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) return;

      setState(() {
        if (isFrontImage) {
          frontImage = File(compressedFile.path);
        } else {
          rearImage = File(compressedFile.path);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog(bool isFrontImage) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose option",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _pickAndCompressImage(ImageSource.camera, isFrontImage);
                    },
                    child: const Text("Camera"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _pickAndCompressImage(ImageSource.gallery, isFrontImage);
                    },
                    child: const Text("Choose from Gallery"),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePreview(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(imageFile),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void applypuc(BuildContext context, {
    required String orderId,
    required int orderAmount,
    required String cfOrderId,
    required String pucID,
  }) async {
    FormData formData = FormData.fromMap({
      "vehicle_type": selectedVehicleType,
      "rc": vehicleNumberController.text,
      "vehicle_model": vehicleModelController.text,
      "vehicle_name": vehicleNameController.text,
      "order_id": orderId,
      "order_amount": orderAmount,
      "cf_order_id": cfOrderId,
      "puc_id": pucID,
      "vehicle_front_ph": await MultipartFile.fromFile(
        frontImage!.path,
        filename: frontImage!.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      ),
      "vehicle_back_ph": await MultipartFile.fromFile(
        rearImage!.path,
        filename: rearImage!.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    final response = await ApiHelper.postMultipart(
      context,
      ApiUrls.applyPUC,
      data: formData,
    );

    if (response != null) {
      String paymentStatus = response.data["data"]?["payments_details"]?["payment_status"] ?? "";
      bool status = response.data["status"] ?? false;

      if (paymentStatus != "SUCCESS") {
        myLogoAlert(
          message: "Payment Failed, Try again.",
          context: context,
          navigateEnabled: false,
          route: '',
        );
      } else if (paymentStatus == "SUCCESS" && !status) {
        myLogoAlert(
          message: "We received your payment but something went wrong, contact support.",
          context: context,
          navigateEnabled: false,
          route: '',
        );
      } else if (paymentStatus == "SUCCESS" && status) {
        myLogoAlert(
          message: "Kindly wait for 15 mins, we are processing your certificate",
          context: context,
          navigateEnabled: true,
          route: Dashboard.id,
        );
      }
    }
  }

  void initiateWebCheckout(String orderId, String paymentSessionId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      var session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.PRODUCTION)//production
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      var cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      var cfPaymentGatewayService = CFPaymentGatewayService();
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      cfPaymentGatewayService.doPayment(cfWebCheckout);

      Navigator.of(context).pop();
    } on CFException catch (e) {
      Navigator.of(context).pop();
      print(e.message);
    }
  }


  void createOrder(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final payload = {
      "order_amount": pucAmount,
    };

    final response = await ApiHelper.post(
      context,
      ApiUrls.createOrder,
      data: payload,
    );

    if (response != null) {
      var responseData = response.data;
      orderId = responseData['order_id'];
      paymentSessionId = responseData['payment_session_id'];
      cfOrderId = responseData['cf_order_id'].toString();
      pucID = responseData['_id'];

      print("Order ID: $orderId");
      print("Payment Session ID: $paymentSessionId");
      print(pucID);
      print(cfOrderId);
      print("Full Response: ${response.data}");

      initiateWebCheckout(orderId, paymentSessionId);
    }

    setState(() {
      isLoading = false;
    });
  }



  void verifyPayment(String orderId) {
    print("Payment successful. Order ID: $orderId");

    print("Payment response: {\"order_id\": \"$orderId\", \"status\": \"SUCCESS\"}");
    applypuc(
        context,
        orderId: orderId,
        orderAmount: pucAmount,
        cfOrderId: cfOrderId,
        pucID: pucID
    );
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print("Error while making payment: ${errorResponse.getMessage()}");
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
          context,
         Dashboard.id,
        );
        return false; 
      },
      child: Scaffold(
        backgroundColor: kColorWhite,
        appBar: AppBar(
          backgroundColor: kColorMidNightBlue,
          title: const Text(
            'Apply For Pollution Certificate',
            style: TextStyle(
              fontSize: 22,
              color: kColorWhite,
              decoration: TextDecoration.none,
            ),
          ),

          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const NewDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100.0),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kColorBase),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kColorBase),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            labelText: 'Select Vehicle Type',
                            labelStyle: TextStyle(color: kColorBase),
                          ),
                          value: selectedVehicleType,
                          items: const [
                            DropdownMenuItem(value: 'Bike', child: Text('2-wheeler')),
                            DropdownMenuItem(value: 'Car Petrol', child: Text('4-wheeler-Petrol')),
                            DropdownMenuItem(value: 'Car Diesel', child: Text('4-wheeler-Diesel')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedVehicleType = value;
                              _updatePucAmount(value);
                            });
                          },
                        ),

                        const SizedBox(height: 15.0),

                        // Vehicle Name
                        MyTextFieldNoIcon(
                          isPassword: false,
                          controller: vehicleNameController,
                          isNumber: false,
                          isLast: false,
                          displayLabel: 'Vehicle Name',
                          onChanged: (val) {
                            setState(() {
                              vehicleNameController.text = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15.0),

                        // Vehicle Number
                        MyTextFieldNoIcon(
                          isPassword: false,
                          controller: vehicleNumberController,
                          isNumber: false,
                          isLast: false,
                          displayLabel: 'Vehicle Number',
                          onChanged: (val) {
                            setState(() {
                              vehicleNumberController.text = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15.0),
                        MyTextFieldNoIcon(
                          isPassword: false,
                          controller: vehicleModelController,
                          isNumber: false,
                          isLast: false,
                          displayLabel: 'Vehicle Model',
                          onChanged: (val) {
                            setState(() {
                              vehicleModelController.text = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15.0),

                        // Image Upload Buttons with Labels
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showImageSourceDialog(true);
                                  },
                                  icon: const Icon(Icons.upload_file, color: kColorWhite),
                                  label: const Text(
                                    'Upload Front Image',
                                    style: TextStyle(color: kColorWhite),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kColorMidNightBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: frontImage != null
                                        ? () => _showImagePreview(frontImage!)
                                        : null,
                                    child: Text(
                                      frontImage != null ? frontImage!.path.split('/').last : '',
                                      style: TextStyle(
                                        color: frontImage != null ? Colors.blue : Colors.grey,
                                        decoration: frontImage != null
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showImageSourceDialog(false);
                                  },
                                  icon: const Icon(Icons.upload_file, color: kColorWhite),
                                  label: const Text(
                                    'Upload Rear Image',
                                    style: TextStyle(color: kColorWhite),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kColorMidNightBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: rearImage != null
                                        ? () => _showImagePreview(rearImage!)
                                        : null,
                                    child: Text(
                                      rearImage != null ? rearImage!.path.split('/').last : '',
                                      style: TextStyle(
                                        color: rearImage != null ? Colors.blue : Colors.grey,
                                        decoration: rearImage != null
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30.0),


                        ElevatedButton(
                          onPressed: () {
                            if (selectedVehicleType == null ||
                                vehicleNameController.text.isEmpty ||
                                vehicleNumberController.text.isEmpty ||
                                vehicleModelController.text.isEmpty ||
                                frontImage == null ||
                                rearImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Fill all details"),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            } else {
                              createOrder(context);
                            }
                          },

                          child: const Text(
                            'Apply',
                            style: TextStyle(color: kColorWhite),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kColorGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50.0,
                              vertical: 15.0,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
