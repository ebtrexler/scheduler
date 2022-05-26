import 'package:flutter/material.dart';
import 'package:mroth_flutter_app/models/user.dart';
import 'package:mroth_flutter_app/editors/text_field_editor.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

class EditUserRoute extends StatefulWidget {
  final User user;

  const EditUserRoute({required this.user, Key? key}) : super(key: key);

  @override
  State<EditUserRoute> createState() => _EditUserRouteState();
}

class _EditUserRouteState extends State<EditUserRoute>
    implements TextFieldChangedListener {
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
                labelText: "Name",
                keyboardType: TextInputType.name,
                listener: this,
              ),
            ),
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


/* 
ListView(
              children: [
                Card(
                    child: ListTile(
                  leading: const Text("Email: "),
                  title: TextField(
                    controller: TextEditingController()
                      ..text = widget.user.email,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.grey),
                        gapPadding: 10.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.green),
                        gapPadding: 10.0,
                      ),
                      labelText: "Email: ",
                      contentPadding: EdgeInsets.all(20.0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      widget.user.email = value;
                    },
                  ),
                )),
                Card(
                    child: ListTile(
                  leading: const Text("Name: "),
                  title: TextField(
                    controller: TextEditingController()
                      ..text = widget.user.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.grey),
                        gapPadding: 10.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.green),
                        gapPadding: 10.0,
                      ),
                      labelText: "Name: ",
                      contentPadding: EdgeInsets.all(20.0),
                    ),
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      widget.user.name = value;
                    },
                  ),
                )),
*/