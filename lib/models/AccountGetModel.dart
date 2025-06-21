// To parse this JSON data, do
//
//     final accountGetResponse = accountGetResponseFromJson(jsonString);

import 'dart:convert';

List<AccountGetResponse> accountGetResponseFromJson(String str) =>
    List<AccountGetResponse>.from(
        json.decode(str).map((x) => AccountGetResponse.fromJson(x)));

String accountGetResponseToJson(List<AccountGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AccountGetResponse {
  int id;
  String balance;
  int usuarioId;
  String name;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  AccountGetResponse({
    required this.id,
    required this.balance,
    required this.usuarioId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountGetResponse.fromJson(Map<String, dynamic> json) =>
      AccountGetResponse(
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
