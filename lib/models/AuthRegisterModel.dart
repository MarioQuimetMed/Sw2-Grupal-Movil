// To parse this JSON data, do
//
//     final authRegister = authRegisterFromJson(jsonString);

import 'dart:convert';

AuthRegister authRegisterFromJson(String str) =>
    AuthRegister.fromJson(json.decode(str));

String authRegisterToJson(AuthRegister data) => json.encode(data.toJson());

class AuthRegister {
  int id;
  String username;
  String email;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  AuthRegister({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthRegister.fromJson(Map<String, dynamic> json) => AuthRegister(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
