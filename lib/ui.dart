//Libs
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
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
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
                child: TextFormField(
              controller: addNewTodoController,
              maxLines: 1,
              onFieldSubmitted: (text) {
                print(text);
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.view_kanban_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                width: 180)
          ]),
          KanbanViewState()
        ]);
      }),
    );
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
      bottomNavigationBar:
          Consumer<GlobalState>(builder: (context, state, widget) {
        return BottomBar(state: state);
      }),
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

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key, required state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return BottomNavigationBar(
        selectedFontSize: 14,
        currentIndex: state.currentNavbarIndex,
        onTap: (value) {
          navigateToPage(
              state, ['home', 'kanban', 'open'][value], value, context);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_3x3),
            label: 'Kanban',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Open',
          ),
        ],
      );
    });
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

class KanbanViewState extends StatefulWidget {
  const KanbanViewState({Key? key}) : super(key: key);

  @override
  State<KanbanViewState> createState() => KanbanView();
}

class KanbanView extends State<KanbanViewState> {
  KanbanView({Key? key}) : super();
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      final config = AppFlowyBoardConfig(
          
          cardPadding: const EdgeInsets.all(8),
          headerPadding: const EdgeInsets.all(16),
          groupItemPadding: EdgeInsets.all(0),
          // groupPadding: const EdgeInsets.symmetric(horizontal: 4),
          groupBackgroundColor: HexColor.fromHex('#000000'),
          stretchGroupHeight: false,
          cornerRadius: 4);
      final AppFlowyBoardController controller = AppFlowyBoardController(
        onMoveGroupItem: (columnName, fromIndex, toIndex) {
          handleOnMoveGroupItem(state, columnName, fromIndex, toIndex);
        },
        onMoveGroupItemToGroup: (fromColumnName, fromIndex, toColumnName, toIndex) {
          handleOnMoveGroupItemToGroup(state, fromColumnName, fromIndex, toColumnName, toIndex);
        },
      );
      for (var column in state.columns) {
        controller.addGroup(
            AppFlowyGroupData(id: column.id, name: column.id, items: []));
        for (var item in state.todos) {
          controller.addGroupItem(item.tags.first, item);
        }
      }
      return AppFlowyBoard(
          controller: controller,
          scrollController: ScrollController(),
          boardScrollController: AppFlowyBoardScrollController(),
          cardBuilder: (context, group, groupItem) {
            final todoItem = groupItem as Todo;
            return AppFlowyGroupCard(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              key: ValueKey(todoItem.id),
              child: TodoCard(todoItem: todoItem),
            );
          },
          headerBuilder: (context, columnData) {
            return AppFlowyGroupHeader(
              onMoreButtonClick: (){},
              
              title: Text(columnData.headerData.groupName),
              height: 80,
              margin: const EdgeInsets.all(0),
            );
          },
          groupConstraints: const BoxConstraints.tightFor(width: 300),
          config: config);
    });
  }
}

class TodoCard extends StatelessWidget {
  final Todo todoItem;
  const TodoCard({Key? key, required this.todoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(builder: (context, state, widget) {
      return Listener(
        onPointerDown: (e) {
          state.setStartedDragTarget(todoItem.id);
        },
        onPointerUp: (e) {
          state.setEndedDragTarget(todoItem.id);
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
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
      ]));
    });
  }
}
