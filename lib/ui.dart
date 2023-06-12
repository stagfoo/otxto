//Libs

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Local
import 'actions.dart';
import 'store.dart';

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
                color: randomStringToHexColor('ff'),
                // border: Border.all(color: Colors.white, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.delete,
                color: Colors.black,
              ),
            );
          },
          onAccept: (String dragInfo) {
            //TODO add animation
            var info = dragInfo.split('_');
            var id = info[0];
            handleDeleteTodo(state, id);
          },
        ),
        body: Consumer<GlobalState>(builder: (context, state, widget) {
          return Padding(
              padding: EdgeInsets.only(top: 16),
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
                          handleSubmitNewTodo(state, text.toLowerCase());
                          addNewTodoController.clear();
                          state.setEditingStatus('', false);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Add new todo in todo.txt format',
                          prefixIcon: Icon(Icons.add),
                        ),
                      )),
                      IconButton(
                          iconSize: 20,
                          onPressed: () {
                            handleCloseFolder(state);
                          },
                          icon: const Icon(Icons.close))
                    ]),
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
      return SizedBox(
          width: 300,
          height: 700,
          child: ListView(scrollDirection: Axis.vertical, children: [
            ColumnTitle(text: columnName),
            DragTarget<String>(
              builder: (context, candidateItems, rejectedItems) {
                var listOfCards = list.map((to) {
                  var card = TodoCard(todoItem: to);
                  return Draggable<String>(
                    data: to.id + '_' + columnId,
                    child: card,
                    feedback: Material(child: card),
                  );
                }).toList();
                return Container(
                    width: 300,
                    height: 500,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(30, 255, 255, 255),
                      // border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView(children: listOfCards));
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
          ]));
    });
  }
}

class SingleColumn extends StatelessWidget {
  final String columnName;
  final String columnId;
  final GlobalState state;
  const SingleColumn(
      {Key? key,
      required this.columnName,
      required this.columnId,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return SizedBox(
          height: 700,
          child: ListView(scrollDirection: Axis.vertical, children: [
            ColumnTitle(text: columnName),
            DragTarget<String>(
              builder: (context, candidateItems, rejectedItems) {
                var list = state.todos.map((to) {
                  var card = TodoCard(todoItem: to);
                  return Draggable<String>(
                    data: to.id + '_' + columnId,
                    child: card,
                    feedback: Material(child: card),
                  );
                }).toList();
                return Container(
                    width: 300,
                    height: 500,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView(children: list));
              },
              onAccept: (String dragInfo) {
                //TODO allow reordering
              },
            )
          ]));
    });
  }
}

class TodoCard extends StatelessWidget {
  final Todo todoItem;
  const TodoCard({Key? key, required this.todoItem}) : super(key: key);
  final double width = 284;
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
                  margin: const EdgeInsetsDirectional.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flex(
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
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.only(
                                    top: 8, left: 8, bottom: 8),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  todoItem.text,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                )),
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

class AddNewColumn extends StatelessWidget {
  final GlobalState state;
  final textController = TextEditingController();
  AddNewColumn({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: SizedBox(
              width: 200,
              child: TextFormField(
                controller: textController,
                maxLines: 1,
                onFieldSubmitted: (text) {
                  //TODO move to actions
                  var name = text[0] == '@' ? text : '@' + text;
                  state.addNewColumn(name.toLowerCase());
                  textController.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Add @tag column',
                  prefixIcon: Icon(Icons.view_kanban_outlined),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 2),
                  ),
                ),
              )));
    });
  }
}

class TagItem extends StatelessWidget {
  final String text;
  const TagItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Container(
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: randomStringToHexColor(text),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 10)));
    });
  }
}

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

class ColumnTitle extends StatelessWidget {
  final String text;
  const ColumnTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return text.isNotEmpty
          ? SizedBox(
              height: 48,
              child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 48,
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Text(
                          text,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                    !restrictedColumns.contains(text)
                        ? IconButton(
                            iconSize: 20,
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
