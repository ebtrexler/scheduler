// To parse this JSON data, do
//
//     final appointment = appointmentFromJson(jsonString);

import 'dart:convert';

import 'package:mroth_flutter_app/models/date_time_field.dart';

class Appointment {
  Appointment(
      {required this.primaryKey,
      required this.userId,
      required this.name,
      required this.dateTimeField,
      required this.location,
      required this.guests});

  String primaryKey;
  String userId;
  String name;
  DateTimeField dateTimeField;
  String location;
  List<String> guests;

  factory Appointment.empty() => Appointment(
      primaryKey: "",
      userId: "",
      name: "",
      dateTimeField: DateTimeField(),
      location: "",
      guests: []);

  factory Appointment.fromRawJson(String str) =>
      Appointment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        primaryKey: json["primaryKey"],
        userId: json["userId"],
        name: json["name"],
        dateTimeField: DateTimeField.fromJson(json["dateTimeField"]),
        location: json["location"],
        guests: List<String>.from(json["guests"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "primaryKey": primaryKey,
        "userId": userId,
        "name": name,
        "dateTimeField": dateTimeField.toJson(),
        "location": location,
        "guests": List<dynamic>.from(guests.map((x) => x)),
      };
}
