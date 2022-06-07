// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

class User {
  User({
    required this.email,
    required this.name,
    this.imageBase64,
  });

  String email;
  String name;
  String? imageBase64;

  factory User.empty() => User(
        email: "",
        name: "",
        imageBase64: null,
      );

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json["email"],
        name: json["name"],
        imageBase64:
            json.containsKey("imageBase64") ? json["imageBase64"] : null,
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "imageBase64": imageBase64,
      };
}
