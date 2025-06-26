// To parse this JSON data, do
//
//     final myPlayGetResponse = myPlayGetResponseFromJson(jsonString);

import 'dart:convert';

MyPlayGetResponse myPlayGetResponseFromJson(String str) =>
    MyPlayGetResponse.fromJson(json.decode(str));

String myPlayGetResponseToJson(MyPlayGetResponse data) =>
    json.encode(data.toJson());

class MyPlayGetResponse {
  UserPlan userPlan;
  bool isSubscribed;

  MyPlayGetResponse({
    required this.userPlan,
    required this.isSubscribed,
  });

  factory MyPlayGetResponse.fromJson(Map<String, dynamic> json) =>
      MyPlayGetResponse(
        userPlan: UserPlan.fromJson(json["userPlan"]),
        isSubscribed: json["isSubscribed"],
      );

  Map<String, dynamic> toJson() => {
        "userPlan": userPlan.toJson(),
        "isSubscribed": isSubscribed,
      };
}

class UserPlan {
  int id;
  int userId;
  int planId;
  DateTime startDate;
  DateTime endDate;
  String paymentStatus;
  Plan plan;

  UserPlan({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    required this.plan,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
        id: json["id"],
        userId: json["user_id"],
        planId: json["plan_id"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        paymentStatus: json["payment_status"],
        plan: Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "plan_id": planId,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "payment_status": paymentStatus,
        "plan": plan.toJson(),
      };
}

class Plan {
  int id;
  String name;
  String description;
  String priceMonthly;
  String priceAnnual;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.priceAnnual,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
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
