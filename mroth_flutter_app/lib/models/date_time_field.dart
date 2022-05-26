import 'dart:convert';

class DateTimeField {
  DateTimeField({
    this.datetime = "",
    this.aMpM = false,
  });

  String datetime;
  bool aMpM;

  factory DateTimeField.fromRawJson(String str) =>
      DateTimeField.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DateTimeField.fromJson(Map<String, dynamic> json) => DateTimeField(
        datetime: json["datetime"],
        aMpM: json["aMpM"],
      );

  Map<String, dynamic> toJson() => {
        "datetime": datetime,
        "aMpM": aMpM,
      };
}
