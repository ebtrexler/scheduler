import 'package:flutter/material.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

abstract class TextFieldChangedListener {
  onTextFieldChanged(String newValue, String editKey);
}

class TextFieldEditor extends StatefulWidget {
  final String editString;
  final String editKey;
  final String labelText;
  final TextInputType keyboardType;
  final bool isEditable;
  final TextFieldChangedListener? listener;
  const TextFieldEditor(
      {required this.editString,
      required this.editKey,
      required this.labelText,
      required this.keyboardType,
      required this.isEditable,
      this.listener,
      Key? key})
      : super(key: key);

  @override
  State<TextFieldEditor> createState() => _TextFieldEditorState();
}

class _TextFieldEditorState extends State<TextFieldEditor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
      child: Card(
          child: Row(children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${widget.labelText}: ",
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 3)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
            child: TextField(
              enabled: widget.isEditable,
              controller: TextEditingController()..text = widget.editString,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey),
                  gapPadding: 10.0,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.green),
                  gapPadding: 10.0,
                ),
                labelText: widget.labelText,
                labelStyle:
                    TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3),
                contentPadding: const EdgeInsets.all(20.0),
              ),
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3),
              keyboardType: widget.keyboardType,
              onChanged: (value) {
                widget.listener?.onTextFieldChanged(value, widget.editKey);
              },
            ),
          ),
        )
      ])),
    );
  }
}
