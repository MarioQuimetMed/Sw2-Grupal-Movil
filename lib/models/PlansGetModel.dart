// To parse this JSON data, do
//
//     final plansGetResponse = plansGetResponseFromJson(jsonString);

import 'dart:convert';

List<PlansGetResponse> plansGetResponseFromJson(String str) =>
    List<PlansGetResponse>.from(
        json.decode(str).map((x) => PlansGetResponse.fromJson(x)));

String plansGetResponseToJson(List<PlansGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlansGetResponse {
  int id;
  String name;
  String description;
  String priceMonthly;
  String priceAnnual;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  PlansGetResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.priceAnnual,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlansGetResponse.fromJson(Map<String, dynamic> json) =>
      PlansGetResponse(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        priceMonthly: json["price_monthly"],
        priceAnnual: json["price_annual"],
        isActive: json["is_active"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price_monthly": priceMonthly,
        "price_annual": priceAnnual,
        "is_active": isActive,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
