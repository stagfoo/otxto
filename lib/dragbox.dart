// stateful widget dragbox
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';



class DragBox extends StatefulWidget {
  String id;

  DragBox(
      {Key? key,
      required this.x,
      required this.y,
      required this.state,
      required this.id,
      required this.child})
      : super(key: key);
  double x;
  double y;
  final GlobalState state;
  Widget child;

  @override
  _DragBoxState createState() => _DragBoxState();
}

class _DragBoxState extends State<DragBox> {
  @override
  Widget build(BuildContext context) {
    final child = Material(
      child: widget.child,
    );
    return Stack(
      children: <Widget>[
  Draggable<String>(
            data: widget.id,
            onDragUpdate: (details) {
              setState(() {
                widget.y = widget.y + details.delta.dy;
                widget.x = widget.x + details.delta.dx;
              });
            },
            child: widget.y == 0 ? child: Container(),
            feedback: child,
          ),
      ],
    );
  }
}
