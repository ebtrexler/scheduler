import 'package:flutter/material.dart';
import 'package:mroth_flutter_app/models/date_time_field.dart';
import 'package:mroth_flutter_app/utils/date_format.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

abstract class DateTimeChangeListener {
  onDateTimeChanged(DateTimeField field, String editKey);
}

class DateTimeEditor extends StatefulWidget {
  final DateTimeField dateTime;
  final String label;
  final String editKey;
  final DateTimeChangeListener? listener;
  const DateTimeEditor(
      {required this.dateTime,
      required this.label,
      required this.editKey,
      this.listener,
      Key? key})
      : super(key: key);

  @override
  State<DateTimeEditor> createState() => _DateTimeEditorState();
}

class _DateTimeEditorState extends State<DateTimeEditor> {
  DateTime? fieldDateTime;

  @override
  void initState() {
    if (widget.dateTime.datetime.isEmpty) {
      fieldDateTime = null;
    } else {
      try {
        fieldDateTime = DateTime.parse(widget.dateTime.datetime);
      } catch (e) {
        fieldDateTime = null;
      }
    }
    super.initState();
  }

  void _datePicker(BuildContext context) async {
    DateTime initial = fieldDateTime ?? DateTime.now();
    DateTime first = DateTime(DateTime.now().year - 5);
    DateTime last = DateTime(DateTime.now().year + 5);
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: initial,
    );
    if (date != null) {
      fieldDateTime = date;
      widget.dateTime.datetime = fieldDateTime!.toIso8601String();
      setState(() {});
    }
  }

  void _timePicker(BuildContext context) async {
    DateTime initial = fieldDateTime ?? DateTime.now();

    TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute));
    if (t != null) {
      fieldDateTime =
          DateTime(initial.year, initial.month, initial.day, t.hour, t.minute);
      widget.dateTime.datetime = fieldDateTime!.toIso8601String();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateText = "";
    if (fieldDateTime != null) {
      dateText = formatDateTime(fieldDateTime!, widget.dateTime.aMpM);
    }

    List<Widget> widgets = <Widget>[
      Expanded(
        flex: 6,
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              )),
              labelText: "Date/Time:",
            ),
            controller: TextEditingController()..text = dateText,
            readOnly: true,
            style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: IconButton(
          icon: Icon(
            widget.dateTime.aMpM ? Icons.twelve_mp : Icons.twenty_four_mp,
            size: SizeConfig.blockSizeHorizontal * 4,
          ),
          onPressed: () {
            setState(() {
              widget.dateTime.aMpM = !widget.dateTime.aMpM;
            });
          },
        ),
      ),
      Expanded(
        flex: 1,
        child: IconButton(
          icon: Icon(
            Icons.date_range_outlined,
            size: SizeConfig.blockSizeHorizontal * 4,
          ),
          onPressed: () => _datePicker(context),
        ),
      ),
      Expanded(
        flex: 1,
        child: IconButton(
          icon: Icon(
            Icons.access_time,
            size: SizeConfig.blockSizeHorizontal * 4,
          ),
          onPressed: () => _timePicker(context),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeVertical),
      child: Card(child: Row(children: widgets)),
    );
  }
}
