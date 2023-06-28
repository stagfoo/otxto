//Libs

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Local
import 'actions.dart';
import 'organisms/todoList.dart';
import 'store.dart';
import 'style.dart';

//------------------------PAGE----------------------------
final addNewTodoController = TextEditingController();

class HomePage extends StatelessWidget {
  final GlobalState state;
  HomePage({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: DragTarget<String>(
          builder: (context, candidateItems, rejectedItems) {
            return Container(
              decoration: BoxDecoration(
                color: randomStringToHexColor('uu'),
                // border: Border.all(color: Colors.white, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              padding: const EdgeInsets.all(16),
              child: const Tooltip(
                  message: "Drag a card here to delete",
                  child: Icon(
                    Icons.delete,
                    color: Colors.black,
                  )),
            );
          },
          onAccept: (String dragInfo) {
            //TODO replace with mascot
            var info = dragInfo.split('_');
            var id = info[0];
            handleDeleteTodo(state, id);
          },
        ),
        body: Consumer<GlobalState>(builder: (context, state, widget) {
          return Padding(
              padding: const EdgeInsets.only(top: 40, left: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Expanded(
                          child: TextFormField(
                        controller: addNewTodoController,
                        maxLines: 1,
                        onTapOutside: (event) {
                          addNewTodoController.clear();
                          state.setEditingStatus('', false);
                        },
                        onFieldSubmitted: (text) {
                          handleSubmitNewTodo(state, text);
                          addNewTodoController.clear();
                          state.setEditingStatus('', false);
                        },
                        decoration: const InputDecoration(
                            hintText: 'Add new todo in todo.txt format',
                            prefixIcon: Icon(Icons.add),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2))),
                      )),
                      Container(
                          decoration: BoxDecoration(
                            color: randomStringToHexColor('uu'),
                            // border: Border.all(color: Colors.white, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.only(left: 8, right: 8),
                          child: IconButton(
                              iconSize: 20,
                              onPressed: () {
                                handleCloseFolder(state);
                              },
                              tooltip: "Close this folder",
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              )))
                    ]),
                    Container(
                      height: 16,
                    ),
                    KanbanView(state: state)
                  ]));
        }));
  }
}

class OpenPage extends StatelessWidget {
  final GlobalState state;
  OpenPage({Key? key, required this.state}) : super(key: key);
  final addNewTodoController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<GlobalState>(builder: (context, state, widget) {
          return OpenView(
            state: state,
          );
        }));
  }
}

class OpenView extends StatelessWidget {
  const OpenView({Key? key, required state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            ElevatedButton(
              style:
                  ButtonStyle(side: MaterialStateProperty.resolveWith((states) {
                return const BorderSide(width: 1, color: Colors.white);
              }), backgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.purpleAccent;
                }
                return Colors.black;
              })),
              onPressed: () {
                handleOnClickNavbar(state, 'open', 0, context);
              },
              child: SizedBox(
                  width: 240,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            child: const Icon(
                              Icons.folder_outlined,
                              color: Colors.white,
                            ),
                            margin: const EdgeInsets.only(right: 4),
                          ),
                          const Text("Open Folder",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ))),
            ),
            ElevatedButton(
              style:
                  ButtonStyle(side: MaterialStateProperty.resolveWith((states) {
                return const BorderSide(width: 1, color: Colors.white);
              }), backgroundColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.purpleAccent;
                }
                return Colors.black;
              })),
              onPressed: () {
                handleOnClickNavbar(state, 'create', 0, context);
              },
              child: SizedBox(
                  width: 240,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            child: const Icon(
                              Icons.folder_outlined,
                              color: Colors.white,
                            ),
                            margin: const EdgeInsets.only(right: 4),
                          ),
                          const Text("New todos",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ))),
            ),
            //TODO add recent?
          ]));
    });
  }
}

// kanban stateless widget
class KanbanView extends StatelessWidget {
  const KanbanView({Key? key, required state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Expanded(
          child: SizedBox(
              child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          TodoColumn(
              list: state.todos.where((t) {
                var allColumns = state.columns.map((c) => c.id).toList();
                return !t.tags.any((tag) => allColumns.contains(tag)) &&
                    t.isComplete == false;
              }).toList(),
              columnId: 'all',
              columnName: 'all',
              state: state),
          ...state.columns.map((column) {
            return TodoColumn(
                list: state.todos.where((t) {
                  return t.tags.contains(column.id) && t.isComplete == false;
                }).toList(),
                columnId: column.id,
                columnName: column.id,
                state: state);
          }),
          TodoColumn(
              list: state.todos.where((t) {
                return t.isComplete;
              }).toList(),
              columnId: 'completed',
              columnName: 'completed',
              state: state),
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
  final List<Todo> list;
  const TodoColumn(
      {Key? key,
      required this.columnName,
      required this.columnId,
      required this.list,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Stack(children: [
        ColumnTitle(text: columnName),
        Container(
            width: 300,
            margin: const EdgeInsets.only(top: 64),
            child: TodoList(
                state: state,
                list: list,
                columnId: columnId,
                columnName: columnName,
                handleOnMoveGroupItemToGroup: handleOnMoveGroupItemToGroup,
                addNewTodoController: addNewTodoController))
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
      return Container(
          padding: const EdgeInsets.only(top: 8, left: 8),
          child: SizedBox(
              width: 300,
              height: 48,
              child: TextFormField(
                  controller: textController,
                  maxLines: 1,
                  onFieldSubmitted: (text) {
                    handleAddNewColumn(state, text);
                    textController.clear();
                  },
                  decoration: const InputDecoration(
                      hintText: 'Add @tag column',
                      prefixIcon: Icon(Icons.view_kanban_outlined),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2))))));
    });
  }
}

class ColumnTitle extends StatelessWidget {
  final String text;
  const ColumnTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      bool isRestrictedColumn = restrictedColumns.contains(text);
      Color bgColor =
          isRestrictedColumn ? Colors.black : randomStringToHexColor(text);
      Color textColor =
          bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      return text.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.white, width: 2)),
              margin: const EdgeInsets.only(bottom: 8, left: 0, right: 8),
              height: 52,
              width: 300,
              child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        //TODO rewrite
                        width: 300 - (36 + (isRestrictedColumn ? 0 : 24)),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.bold),
                        )),
                    !isRestrictedColumn
                        ? IconButton(
                            iconSize: 20,
                            color: textColor,
                            onPressed: () {
                              handleDeleteColumn(state, text);
                            },
                            icon: const Icon(Icons.close))
                        : Container()
                  ]))
          : Container();
    });
  }
}
