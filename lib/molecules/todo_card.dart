import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';
import '../atoms/timestamp.dart';
import '../atoms/project.dart';
import '../atoms/tag.dart';
import '../atoms/priority.dart';

const cardWidth = 300.0;

class TodoCard extends StatelessWidget {
  final Todo todoItem;
  final TextEditingController addNewTodoController;
  const TodoCard(
      {Key? key, required this.todoItem, required this.addNewTodoController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: todoItem.isComplete ? 0.5 : 1,
        child: GestureDetector(
            onDoubleTap: () {
              addNewTodoController.value =
                  TextEditingValue(text: todoItem.toString());
              context.read<GlobalState>().setEditingStatus(todoItem.id, true);
            },
            child: Container(
                width: cardWidth,
                padding: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Priority(text: todoItem.priority),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(
                                top: 4, left: 8, right: 8, bottom: 8),
                            child: Text(
                              todoItem.text,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                          )),
                        ],
                      ),
                      if (todoItem.tags.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Wrap(runSpacing: 8, children: [
                              for (var tag in todoItem.tags) TagItem(text: tag)
                            ])),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TimeStamp(text: todoItem.createdAt),
                          Flexible(child: ProjectItem(text: todoItem.project))
                        ],
                      ),
                    ]))));
  }
}
