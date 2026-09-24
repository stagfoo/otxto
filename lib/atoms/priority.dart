import 'package:flutter/material.dart';

class Priority extends StatelessWidget {
  final String text;
  const Priority({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(left: 4),
        decoration: const BoxDecoration(
            color: Color.fromARGB(31, 0, 0, 0),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ));
  }
}
