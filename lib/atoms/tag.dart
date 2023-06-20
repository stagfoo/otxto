import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';
import '../style.dart';

class TagItem extends StatelessWidget {
  final String text;
  const TagItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = randomStringToHexColor(text);
    Color textColor =
        bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Container(
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(text, style: TextStyle(color: textColor, fontSize: 10)));
    });
  }
}
