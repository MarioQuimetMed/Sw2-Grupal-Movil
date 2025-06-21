// To parse this JSON data, do
//
//     final transactionCreateResponse = transactionCreateResponseFromJson(jsonString);

import 'dart:convert';

TransactionCreateResponse transactionCreateResponseFromJson(String str) =>
    TransactionCreateResponse.fromJson(json.decode(str));

String transactionCreateResponseToJson(TransactionCreateResponse data) =>
    json.encode(data.toJson());

class TransactionCreateResponse {
  int id;
  int amount;
  DateTime date;
  String description;
  int idAccount;
  String type;
  int idCategory;
  DateTime createdAt;
  DateTime updatedAt;

  TransactionCreateResponse({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.idAccount,
    required this.type,
    required this.idCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionCreateResponse.fromJson(Map<String, dynamic> json) =>
      TransactionCreateResponse(
        id: json["id"],
        amount: json["amount"],
        date: DateTime.parse(json["date"]),
        description: json["description"],
        idAccount: json["idAccount"],
        type: json["type"],
        idCategory: json["idCategory"],
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
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
