import 'package:flutter/material.dart';
import 'package:mroth_flutter_app/models/date_time_field.dart';
import 'package:mroth_flutter_app/editors/datetime_editor.dart';
import 'package:mroth_flutter_app/editors/text_field_editor.dart';
import 'package:mroth_flutter_app/editors/choice_field_editor.dart';
import 'package:mroth_flutter_app/models/appointment.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

// ignore: must_be_immutable
class EditAppointmentRoute extends StatefulWidget {
  Appointment appt;
  List<String> usersWhoCanBeGuests;
  bool isEditable;
  EditAppointmentRoute(
      {required this.appt,
      required this.usersWhoCanBeGuests,
      required this.isEditable,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditAppointmentState();
}

class _EditAppointmentState extends State<EditAppointmentRoute>
    implements
        TextFieldChangedListener,
        ChoiceFieldChangedListener,
        DateTimeChangeListener {
  _EditAppointmentState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Appointment",
          style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                Navigator.pop(context, widget.appt);
              }),
        ],
      ),
      body: Center(
        child: ListView(
          children: _getRows(),
        ),
      ),
    );
  }

  List<Widget> _getRows() {
    List<Widget> cards = [];
    cards.add(TextFieldEditor(
        editString: widget.appt.name,
        editKey: "name",
        labelText: "Name",
        isEditable: widget.isEditable,
        keyboardType: TextInputType.name,
        listener: this));
    cards.add(DateTimeEditor(
        dateTime: widget.appt.dateTimeField,
        isEditable: widget.isEditable,
        editKey: "datetime",
        label: "Date/Time",
        listener: this));
    cards.add(TextFieldEditor(
        editString: widget.appt.location,
        editKey: "location",
        labelText: "Location",
        isEditable: widget.isEditable,
        keyboardType: TextInputType.streetAddress,
        listener: this));
    cards.add(ChoiceFieldEditor(
        choices: widget.usersWhoCanBeGuests,
        selections: widget.appt.guests,
        editKey: "guests",
        label: "Guests",
        listener: this));

    return cards;
  }

  @override
  onTextFieldChanged(String newValue, String editKey) {
    if (!widget.isEditable) return;
    switch (editKey) {
      case "name":
        widget.appt.name = newValue;
        break;
      case "location":
        widget.appt.location = newValue;
        break;
    }
  }

  @override
  onChoiceFieldChanged(List<String> selections, String editKey) {
    if (editKey == "guests") {
      widget.appt.guests.clear();
      widget.appt.guests.addAll(selections);
    }
  }

  @override
  onDateTimeChanged(DateTimeField field, String editKey) {
    if (!widget.isEditable) return;
    if (editKey == "datetime") {
      widget.appt.dateTimeField =
          DateTimeField(datetime: field.datetime, aMpM: field.aMpM);
    }
  }
}
