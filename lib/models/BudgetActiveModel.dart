// To parse this JSON data, do
//
//     final budgetActiveGet = budgetActiveGetFromJson(jsonString);

import 'dart:convert';

List<BudgetActiveGet> budgetActiveGetFromJson(String str) =>
    List<BudgetActiveGet>.from(
        json.decode(str).map((x) => BudgetActiveGet.fromJson(x)));

String budgetActiveGetToJson(List<BudgetActiveGet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BudgetActiveGet {
  int id;
  int amount;
  String description;
  DateTime startDate;
  DateTime endDate;
  int idAccount;
  Account account;
  DateTime createdAt;
  DateTime updatedAt;

  BudgetActiveGet({
    required this.id,
    required this.amount,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.idAccount,
    required this.account,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetActiveGet.fromJson(Map<String, dynamic> json) =>
      BudgetActiveGet(
        id: json["id"],
        amount: json["amount"],
        description: json["description"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        idAccount: json["idAccount"],
        account: Account.fromJson(json["account"]),
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
        "account": account.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Account {
  int id;
  String balance;
  int usuarioId;
  String name;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Account({
    required this.id,
    required this.balance,
    required this.usuarioId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        balance: json["balance"],
        usuarioId: json["usuarioId"],
        name: json["name"],
        isActive: json["is_active"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "balance": balance,
        "usuarioId": usuarioId,
        "name": name,
        "is_active": isActive,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
