import 'package:flutter/material.dart';

class ProjectItem extends StatelessWidget {
  final String text;
  const ProjectItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
        margin: const EdgeInsets.only(left: 4, right: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(66, 206, 206, 206),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Text("📁 " + text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontSize: 10)));
  }
}
