import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';

class ProjectItem extends StatelessWidget {
  final String text;
  const ProjectItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return text.isNotEmpty
          ? Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(66, 206, 206, 206),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Text("📁 " + text,
                  style: const TextStyle(color: Colors.black, fontSize: 10)))
          : Container();
    });
  }
}
