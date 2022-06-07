import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mroth_flutter_app/models/user.dart';
import 'package:mroth_flutter_app/editors/text_field_editor.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

class EditUserRoute extends StatefulWidget {
  final User user;
  final bool isEditable; // false when editing user because email can' change

  const EditUserRoute({required this.user, required this.isEditable, Key? key})
      : super(key: key);

  @override
  State<EditUserRoute> createState() => _EditUserRouteState();
}

class _EditUserRouteState extends State<EditUserRoute>
    implements TextFieldChangedListener {
  final ImagePicker _picker = ImagePicker();

  Image? img;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
        onWillPop: () {
          return Future(() => true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Edit User",
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
            ),
            actions: [
              IconButton(
                  icon: const Icon(
                    Icons.save,
                  ),
                  onPressed: () {
                    Navigator.pop(context, widget.user);
                  }),
            ],
          ),
          body: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFieldEditor(
                editString: widget.user.email,
                editKey: "email",
                isEditable: widget.isEditable,
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
                listener: this,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFieldEditor(
                editString: widget.user.name,
                editKey: "name",
                isEditable: true,
                labelText: "Name",
                keyboardType: TextInputType.name,
                listener: this,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final XFile? imgFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxHeight: 200.0,
                  maxWidth: 200.0,
                );
                if (imgFile != null) {
                  widget.user.imageBase64 = const Base64Encoder()
                      .convert(File(imgFile.path).readAsBytesSync());
                }
                setState(() {});
              },
              child: Text(
                "Add/Change Image",
                style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
              ),
            ),
            (widget.user.imageBase64 != null)
                ? Image.memory(
                    const Base64Decoder().convert(widget.user.imageBase64!))
                : Container(),
          ]),
        ));
  }

  @override
  onTextFieldChanged(String newValue, String editKey) {
    switch (editKey) {
      case "name":
        widget.user.name = newValue;
        break;
      case "email":
        widget.user.email = newValue;
        break;
    }
  }
}
