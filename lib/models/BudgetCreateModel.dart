// To parse this JSON data, do
//
//     final budgetCreateResponse = budgetCreateResponseFromJson(jsonString);

import 'dart:convert';

BudgetCreateResponse budgetCreateResponseFromJson(String str) =>
    BudgetCreateResponse.fromJson(json.decode(str));

String budgetCreateResponseToJson(BudgetCreateResponse data) =>
    json.encode(data.toJson());

class BudgetCreateResponse {
  int id;
  int amount;
  String description;
  DateTime startDate;
  DateTime endDate;
  int idAccount;
  DateTime createdAt;
  DateTime updatedAt;

  BudgetCreateResponse({
    required this.id,
    required this.amount,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.idAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetCreateResponse.fromJson(Map<String, dynamic> json) =>
      BudgetCreateResponse(
        id: json["id"],
        amount: json["amount"],
        description: json["description"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        idAccount: json["idAccount"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "description": description,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "idAccount": idAccount,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
