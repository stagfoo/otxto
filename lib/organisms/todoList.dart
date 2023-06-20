import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../actions.dart';
import '../store.dart';
import '../molecules/todoCard.dart';

class TodoList extends StatelessWidget {
  final String columnName;
  final String columnId;
  final handleOnMoveGroupItemToGroup;
  //TODO kinda weird this is here
  final TextEditingController addNewTodoController;
  final GlobalState state;
  final List<Todo> list;
  const TodoList(
      {Key? key,
      required this.columnName,
      required this.columnId,
      required this.list,
      required this.handleOnMoveGroupItemToGroup,
      required this.state,
      required this.addNewTodoController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return ListView(scrollDirection: Axis.vertical, children: [
        DragTarget<String>(
          builder: (context, candidateItems, rejectedItems) {
            var listOfCards = list.map((to) {
              var card = TodoCard(
                todoItem: to,
                addNewTodoController: addNewTodoController,
              );
              return Draggable<String>(
                data: to.id + '_' + columnId,
                child: Container(
                  child: card,
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                feedback: Material(
                  child: card,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList();
            return Container(
                width: 300,
                padding: const EdgeInsets.only(bottom: 1000),
                // margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(30, 255, 255, 255),
                  // border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Flex(
                  children: listOfCards,
                  direction: Axis.vertical,
                ));
          },
          onAccept: (String dragInfo) {
            var info = dragInfo.split('_');
            var id = info[0];
            var fromColumn = info[1];
            if (columnId[0] == '@') {
              handleOnMoveGroupItemToGroup(state, fromColumn, id, columnId);
            } else {
              handleOnMoveGroupItemToGroup(state, fromColumn, id, columnId);
            }
          },
        )
      ]);
    });
  }
}
