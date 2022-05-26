import 'package:flutter/material.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

abstract class ChoiceFieldChangedListener {
  onChoiceFieldChanged(List<String> selections, String editKey);
}

class ChoiceFieldEditor extends StatefulWidget {
  final List<String> choices;
  final List<String> selections;
  final String label;
  final String editKey;
  final ChoiceFieldChangedListener? listener;
  const ChoiceFieldEditor(
      {required this.choices,
      required this.selections,
      required this.label,
      required this.editKey,
      this.listener,
      Key? key})
      : super(key: key);

  @override
  State<ChoiceFieldEditor> createState() => _ChoiceFieldEditorState();
}

class _ChoiceFieldEditorState extends State<ChoiceFieldEditor> {
  List<ChoiceChip> chips = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
      child: Card(
          child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style:
                        TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3),
                  ),
                ],
              )),
          Expanded(
            flex: 8,
            child: _getChoicesWidget(),
          ),
        ],
      )),
    );
  }

  Widget _getChoicesWidget() {
    if (widget.choices.isEmpty) {
      return Wrap(
        alignment: WrapAlignment.center,
        children: chips,
      );
    }

    chips.clear();
    for (var choice in widget.choices) {
      var isSelected = widget.selections.contains(choice);
      chips.add(ChoiceChip(
        label: Text(
          choice,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: SizeConfig.blockSizeHorizontal * 3),
        ),
        selected: isSelected,
        selectedColor: Colors.red,
        onSelected: (selected) {
          setState(() {
            isSelected
                ? widget.selections.remove(choice)
                : widget.selections.add(choice);
          });
        },
      ));
    }

    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: chips,
      ),
    );
  }
}
