// To parse this JSON data, do
//
//     final bannerModel = bannerModelFromJson(jsonString);

import 'dart:convert';

BannerModel bannerModelFromJson(String str) => BannerModel.fromJson(json.decode(str));

String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  String code;
  bool status;
  String message;
  Result result;

  BannerModel({
    required this.code,
    required this.status,
    required this.message,
    required this.result,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
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
  String title;
  String image;
  String sortOrder;
  String active;
  String createdBy;
  String createdIp;
  DateTime createdDatetime;
  String modifiedBy;
  dynamic modifiedIp;
  DateTime modifiedDatetime;

  Detail({
    required this.id,
    required this.title,
    required this.image,
    required this.sortOrder,
    required this.active,
    required this.createdBy,
    required this.createdIp,
    required this.createdDatetime,
    required this.modifiedBy,
    required this.modifiedIp,
    required this.modifiedDatetime,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    title: json["title"],
    image: json["image"],
    sortOrder: json["sort_order"],
    active: json["active"],
    createdBy: json["created_by"],
    createdIp: json["created_ip"],
    createdDatetime: DateTime.parse(json["created_datetime"]),
    modifiedBy: json["modified_by"],
    modifiedIp: json["modified_ip"],
    modifiedDatetime: DateTime.parse(json["modified_datetime"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image,
    "sort_order": sortOrder,
    "active": active,
    "created_by": createdBy,
    "created_ip": createdIp,
    "created_datetime": createdDatetime.toIso8601String(),
    "modified_by": modifiedBy,
    "modified_ip": modifiedIp,
    "modified_datetime": modifiedDatetime.toIso8601String(),
  };
}
