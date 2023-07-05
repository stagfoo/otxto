import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';

class Priority extends StatelessWidget {
  final String text;
  const Priority({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return text.isNotEmpty
          ? Container(
              width: 32,
              height: 32,
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 0, left: 4, bottom: 0),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(31, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Center(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ))
          : Container();
    });
  }
}
