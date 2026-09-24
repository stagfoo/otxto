import 'package:flutter/material.dart';

class TimeStamp extends StatelessWidget {
  final String text;
  const TimeStamp({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            style: const TextStyle(color: Colors.grey, fontSize: 12)));
  }
}
