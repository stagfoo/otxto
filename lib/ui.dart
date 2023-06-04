//Libs
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:oxtxto/dragbox.dart';
import 'package:provider/provider.dart';

//Local
import 'actions.dart';
import 'store.dart';
import 'style.dart';

//------------------------PAGE----------------------------

class HomePage extends StatelessWidget {
  final GlobalState state;
  HomePage({Key? key, required this.state}) : super(key: key);
  final addNewTodoController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<GlobalState>(builder: (context, state, widget) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Expanded(
                      child: TextFormField(
                    controller: addNewTodoController,
                    maxLines: 1,
                    onFieldSubmitted: (text) {
                      handleSubmitNewTodo(state, text);
                      addNewTodoController.clear();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Add new todo',
                      prefixIcon: Icon(Icons.add),
                    ),
                  )),
                  SizedBox(
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        buttonPadding: const EdgeInsets.all(8),
                        children: [
                          IconButton(
                            icon: const Icon(Icons.folder_outlined),
                            onPressed: () {
                              handleOnClickNavbar(state, 'open', 0, context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.list),
                            onPressed: () {
                              handleOnClickNavbar(state, 'list', 1, context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.view_kanban_outlined),
                            onPressed: () {
                              handleOnClickNavbar(state, 'kanban', 2, context);
                            },
                          ),
                        ],
                      ),
                      width: 180)
                ]),
                KanbanView(state: state)
              ]);
        }));
  }
}

class OtherPage extends StatelessWidget {
  final GlobalState state;
  const OtherPage({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Other Page"),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      body: Stack(
        children: [
          Consumer<GlobalState>(builder: (context, state, widget) {
            return Container();
          }),
        ],
      ),
    );
  }
}

class TodoView extends StatelessWidget {
  const TodoView({Key? key, required state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Container();
    });
  }
}

// kanban stateless widget
class KanbanView extends StatelessWidget {
  const KanbanView({Key? key, required state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Expanded(child: SizedBox(
        child:ListView(
          shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          ...state.columns.map((column) {
            return TodoColumn(
                columnId: column.id, columnName: column.id, state: state);
          }),
          AddNewColumn(state: state)
        ],
      )));
    });
  }
}

class TodoColumn extends StatelessWidget {
  final String columnName;
  final String columnId;
  final GlobalState state;
  const TodoColumn(
      {Key? key,
      required this.columnName,
      required this.columnId,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return SizedBox(
          width: 300,
          height: 700,
        child: ListView(
        scrollDirection: Axis.vertical,
        children: [
        Container(
            margin: const EdgeInsetsDirectional.only(bottom: 8),
            decoration: BoxDecoration(
              color: HexColor.fromHex('#ffffff'),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            child: Text(
              columnName,
              style: const TextStyle(color: Colors.black),
            )),
        DragTarget<String>(
          builder: (context, candidateItems, rejectedItems) {
            var list = state.todos.where((t) {
              return t.tags.contains(columnId);
            }).map((to) {
              return DragBox(
                  x: 0,
                  y: 0,
                  id: to.id + '_' + columnId,
                  state: state,
                  child: TodoCard(todoItem: to));
            }).toList();
            return Container(
                height: 300,
                width: 300,
                color: Colors.blue,
                child: ListView(children: list));
          },
          onAccept: (String dragInfo) {
            var info = dragInfo.split('_');
            var id = info[0];
            var fromColumn = info[1];
            handleOnMoveGroupItemToGroup(state, fromColumn, id, columnId);
          },
        )
      ]));
    });
  }
}

class TodoCard extends StatelessWidget {
  final Todo todoItem;
  const TodoCard({Key? key, required this.todoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 300,
            margin: const EdgeInsetsDirectional.only(bottom: 8),
            decoration: BoxDecoration(
              color: HexColor.fromHex('#ffffff'),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            child: Text(
              todoItem.text,
              style: const TextStyle(color: Colors.black),
            )),
        Container(
            margin: const EdgeInsetsDirectional.only(bottom: 8),
            child: Stack(children: [
              Text(todoItem.createdAt,
                  style: const TextStyle(color: Colors.white))
            ]))
      ]);
    });
  }
}

class AddNewColumn extends StatelessWidget {
  final GlobalState state;
  final textController = TextEditingController();
  AddNewColumn({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return SizedBox(
        width: 300,
        child: TextFormField(
        controller: textController,
        maxLines: 1,
        onFieldSubmitted: (text) {
          var name = text[0] == '@' ? text : '@' + text;
          state.addNewColumn(text);
          handleSubmitNewTodo(state, text);
          textController.clear();
        },
        decoration: const InputDecoration(
          hintText: 'Add new column',
          prefixIcon: Icon(Icons.view_kanban_outlined),
        ),
      ));
    });
  }
}
