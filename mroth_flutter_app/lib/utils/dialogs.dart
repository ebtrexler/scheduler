import 'dart:ui';

import 'package:flutter/material.dart';

class Dialogs {
  static Future<String> getStringFromUser(
      {required BuildContext context,
      required String title,
      String label = "",
      String hint = "",
      TextInputType keyboardType = TextInputType.text,
      bool allowNull = true}) async {
    String result = "";

    var cancelButton = SimpleDialogOption(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.pop(
            context,
          );
        });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  )),
                  labelText: label,
                  hintText: hint,
                ),
                onChanged: (text) {
                  result = text;
                },
                autofocus: true,
                keyboardType: keyboardType,
                textCapitalization: TextCapitalization.none,
                onEditingComplete: () {
                  result = getResult(result, allowNull, context);
                },
              ),
            ),
            SimpleDialogOption(
              child: const Text("Accept"),
              onPressed: () {
                result = getResult(result, allowNull, context);
              },
            ),
            allowNull ? Container() : cancelButton,
          ],
        );
      },
    );

    return result;
  }

  static String getResult(String result, bool allowNull, BuildContext context) {
    if (allowNull) {
      Navigator.pop(
        context,
      );
      return result;
    } else {
      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("The input cannot be empty."),
          duration: Duration(milliseconds: 1500),
        ));
        return "";
      } else {
        Navigator.pop(
          context,
        );
        return result;
      }
    }
  }

  static Future<bool> getYesNo({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    bool result = false;
    const TextStyle textStyle = TextStyle(color: Colors.black);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
          ),
          content: Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Continue"),
              onPressed: () {
                Navigator.of(context).pop();
                result = true;
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return result;
  }
}

class BlurryDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback continueCallBack;

  const BlurryDialog(this.title, this.content, this.continueCallBack,
      {Key? key})
      : super(key: key);
  final TextStyle textStyle = const TextStyle(
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: Text(
            title,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
          content: Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Continue"),
              onPressed: () {
                Navigator.of(context).pop();
                continueCallBack();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
