import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';

class TimeStamp extends StatelessWidget {
  final String text;
  const TimeStamp({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return text.isNotEmpty
          ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(text,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)))
            ])
          : Container();
    });
  }
}
