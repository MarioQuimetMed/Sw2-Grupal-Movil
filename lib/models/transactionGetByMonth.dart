// To parse this JSON data, do
//
//     final transactionGetByMonth = transactionGetByMonthFromJson(jsonString);

import 'dart:convert';

List<TransactionGetByMonth> transactionGetByMonthFromJson(String str) =>
    List<TransactionGetByMonth>.from(
        json.decode(str).map((x) => TransactionGetByMonth.fromJson(x)));

String transactionGetByMonthToJson(List<TransactionGetByMonth> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransactionGetByMonth {
  int id;
  String amount;
  DateTime date;
  String description;
  int idAccount;
  String type;
  int idCategory;
  Category category;
  DateTime createdAt;
  DateTime updatedAt;

  TransactionGetByMonth({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.idAccount,
    required this.type,
    required this.idCategory,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionGetByMonth.fromJson(Map<String, dynamic> json) =>
      TransactionGetByMonth(
        id: json["id"],
        amount: json["amount"],
        date: DateTime.parse(json["date"]),
        description: json["description"],
        idAccount: json["idAccount"],
        type: json["type"],
        idCategory: json["idCategory"],
        category: Category.fromJson(json["category"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "date": date.toIso8601String(),
        "description": description,
        "idAccount": idAccount,
        "type": type,
        "idCategory": idCategory,
        "category": category.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Category {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
