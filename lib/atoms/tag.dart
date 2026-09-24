import 'package:flutter/material.dart';

import '../style.dart';

class TagItem extends StatelessWidget {
  final String text;
  const TagItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bgColor = randomStringToHexColor(text);
    return Container(
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Text(text,
            style:
                TextStyle(color: contrastingTextColor(bgColor), fontSize: 10)));
  }
}
