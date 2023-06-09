//Libs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mix/mix.dart';
import 'package:provider/provider.dart';

//Local
import 'actions.dart';
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
          return FloatingActionButton(
            backgroundColor: randomStringToHexColor('ff'),
            onPressed: () {},
            child: const Icon(Icons.delete),
          );
        }, onAccept: (String dragInfo) {
          //TODO add animation
          var info = dragInfo.split('_');
          var id = info[0];
          handleDeleteTodo(state, id);
        }),
        body: Consumer<GlobalState>(builder: (context, state, widget) {
          return Column(
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
                      hintText: 'Add new todo',
                      prefixIcon: Icon(Icons.add),
                    ),
                  )),
                  Navbar(state: state),
                ]),
                KanbanView(state: state)
              ]);
        }));
  }
}

class ListPage extends StatelessWidget {
  final GlobalState state;
  ListPage({Key? key, required this.state}) : super(key: key);
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
                  Navbar(state: state),
                ]),
                //TODO remove unused params
                SingleColumn(columnId: '', columnName: '', state: state)
              ]);
        }));
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
                      border: Border.all(color: Colors.white, width: 1),
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
  TodoCard({Key? key, required this.todoItem}) : super(key: key);
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
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsetsDirectional.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: width,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.topLeft,
                            child: Text(
                              todoItem.text,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            )),
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
                                  TimeStamp(text: todoItem.createdAt),
                                ]))
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
          padding: EdgeInsets.symmetric(vertical: 36, horizontal: 8),
          child: SizedBox(
              width: 200,
              child: TextFormField(
                //TODO get all tags in a the file
                autofillHints: ['@doing'],
                controller: textController,
                maxLines: 1,
                onFieldSubmitted: (text) {
                  //TODO move to actions
                  var name = text[0] == '@' ? text : '@' + text;
                  state.addNewColumn(name);
                  textController.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Add new column',
                  prefixIcon: Icon(Icons.view_kanban_outlined),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
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
          margin: EdgeInsets.only(left: 4),
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
          ? Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Container(
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.white),
                      )),
                  !restrictedColumns.contains(text)
                      ? IconButton(
                          iconSize: 20,
                          onPressed: () {
                            handleDeleteColumn(state, text);
                          },
                          icon: Icon(Icons.close))
                      : Container()
                ])
          : Container();
    });
  }
}

class Navbar extends StatelessWidget {
  final GlobalState state;
  const Navbar({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return SizedBox(
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
              // NOTE: Disable
              // IconButton(
              //   icon: const Icon(Icons.list),
              //   onPressed: () {
              //     handleOnClickNavbar(state, 'list', 1, context);
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.view_kanban_outlined),
                onPressed: () {
                  handleOnClickNavbar(state, 'kanban', 2, context);
                },
              ),
            ],
          ),
          width: 180);
    });
  }
}
