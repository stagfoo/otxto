import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';
import '../atoms/timestamp.dart';
import '../atoms/project.dart';
import '../atoms/tag.dart';

class TodoCard extends StatelessWidget {
  final Todo todoItem;
  final TextEditingController addNewTodoController;
  const TodoCard(
      {Key? key, required this.todoItem, required this.addNewTodoController})
      : super(key: key);
  final double width = 300;
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Opacity(
          opacity: todoItem.isComplete ? 0.5 : 1,
          child: GestureDetector(
              onDoubleTap: () {
                addNewTodoController.value =
                    TextEditingValue(text: todoItem.toString());
                state.setEditingStatus(todoItem.id, true);
              },
              child: Container(
                  width: width,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          direction: Axis.horizontal,
                          children: [
                            todoItem.priority.isNotEmpty
                                ? Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(
                                        top: 4, left: 4, bottom: 4),
                                    decoration: const BoxDecoration(
                                        color: Color.fromARGB(31, 0, 0, 0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    child: Center(
                                      child: Text(todoItem.priority,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ))
                                : Container(),
                            Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.only(
                                    top: 8, left: 8, right: 8, bottom: 8),
                                alignment: Alignment.topLeft,
                                child: Wrap(children: [
                                  Text(
                                    todoItem.text,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  )
                                ])),
                          ],
                        ),
                        Container(
                            width: width,
                            color: Colors.transparent,
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsetsDirectional.only(bottom: 8),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  todoItem.tags.isNotEmpty
                                      ? SizedBox(
                                          width: 300,
                                          child: Wrap(
                                              spacing: 0,
                                              runSpacing: 8,
                                              children: [
                                                ...todoItem.tags.map((tag) {
                                                  return TagItem(text: tag);
                                                })
                                              ]))
                                      : Container(),
                                ])),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TimeStamp(text: todoItem.createdAt),
                            Flexible(child: ProjectItem(text: todoItem.project))
                          ],
                        ),
                      ]))));
    });
  }
}
