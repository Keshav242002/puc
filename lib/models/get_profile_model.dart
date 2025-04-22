// To parse this JSON data, do
//
//     final getprofilemodel = getprofilemodelFromJson(jsonString);

import 'dart:convert';

Getprofilemodel getprofilemodelFromJson(String str) => Getprofilemodel.fromJson(json.decode(str));

String getprofilemodelToJson(Getprofilemodel data) => json.encode(data.toJson());

class Getprofilemodel {
  String code;
  bool status;
  String message;
  Result result;

  Getprofilemodel({
    required this.code,
    required this.status,
    required this.message,
    required this.result,
  });

  factory Getprofilemodel.fromJson(Map<String, dynamic> json) => Getprofilemodel(
    code: json["code"],
    status: json["status"],
    message: json["message"],
    result: Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "message": message,
    "result": result.toJson(),
  };
}

class Result {
  List<Detail> details;

  Result({
    required this.details,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "details": List<dynamic>.from(details.map((x) => x.toJson())),
  };
}

class Detail {
  String id;
  String name;
  String email;
  String mobile;
  String password;
  String state;
  String city;
  String active;
  String notificationToken;
  String addedBy;
  String createdBy;
  String createdIp;
  DateTime createdDatetime;
  String modifiedBy;
  dynamic modifiedIp;
  String modifiedDatetime;

  Detail({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.state,
    required this.city,
    required this.active,
    required this.notificationToken,
    required this.addedBy,
    required this.createdBy,
    required this.createdIp,
    required this.createdDatetime,
    required this.modifiedBy,
    required this.modifiedIp,
    required this.modifiedDatetime,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    password: json["password"],
    state: json["state"],
    city: json["city"],
    active: json["active"],
    notificationToken: json["notification_token"],
    addedBy: json["added_by"],
    createdBy: json["created_by"],
    createdIp: json["created_ip"],
    createdDatetime: DateTime.parse(json["created_datetime"]),
    modifiedBy: json["modified_by"],
    modifiedIp: json["modified_ip"],
    modifiedDatetime: json["modified_datetime"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "password": password,
    "state": state,
    "city": city,
    "active": active,
    "notification_token": notificationToken,
    "added_by": addedBy,
    "created_by": createdBy,
    "created_ip": createdIp,
    "created_datetime": createdDatetime.toIso8601String(),
    "modified_by": modifiedBy,
    "modified_ip": modifiedIp,
    "modified_datetime": modifiedDatetime,
  };
}
