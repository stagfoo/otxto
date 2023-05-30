//Libs
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Local
import 'actions.dart';
import 'store.dart';
import 'example.dart';

//------------------------PAGE----------------------------

class HomePage extends StatelessWidget {
  final GlobalState state;
  HomePage({Key? key, required this.state}) : super(key: key);
  final addNewTodoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<GlobalState>(builder: (context, state, widget) {
        return 
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: TextFormField(
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
                IconButton (
                  icon: const Icon(Icons.folder_outlined),
                  onPressed: (){},
                ),
                IconButton (
                  icon: const Icon(Icons.list),
                  onPressed: (){},
                ),
                 IconButton (
                  icon: const Icon(Icons.view_kanban_outlined),
                  onPressed: (){},
                ),
              ],
            ), width: 180)
          ])
          ,
          KanbanView(state: state)
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
          },
          child: const Icon(Icons.add)),
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
          navigateToPage(state, ['home', 'kanban', 'open'][value], value, context);
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

class KanbanView extends StatelessWidget {
  KanbanView({Key? key, required state}) : super(key: key);
  final  boardController = AppFlowyBoardScrollController();
  final AppFlowyBoardController controller = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move item from $fromIndex to $toIndex');
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
    },
  );
  
      final group1 = AppFlowyGroupData(id: "To Do", name: "To Do", items: [
      TextItem("Card 1"),
      TextItem("Card 2"),
      RichTextItem(title: "Card 3", subtitle: 'Aug 1, 2020 4:05 PM'),
      TextItem("Card 4"),
      TextItem("Card 5"),
      TextItem("Card 6"),
      RichTextItem(title: "Card 7", subtitle: 'Aug 1, 2020 4:05 PM'),
      RichTextItem(title: "Card 8", subtitle: 'Aug 1, 2020 4:05 PM'),
      TextItem("Card 9"),
    ]);

    final group2 = AppFlowyGroupData(
      id: "In Progress",
      name: "In Progress",
      items: <AppFlowyGroupItem>[
        RichTextItem(title: "Card 10", subtitle: 'Aug 1, 2020 4:05 PM'),
        TextItem("Card 11"),
      ],
    );

    final group3 = AppFlowyGroupData(
        id: "Done", name: "Done", items: <AppFlowyGroupItem>[]);

  @override
  Widget build(BuildContext context) {
    controller.addGroup(group1);
    // controller.addGroup(group2);
    // controller.addGroup(group3);
    return Consumer<GlobalState>(builder: (context, state, widget) {
      final config = AppFlowyBoardConfig(
        cardPadding: const EdgeInsets.all(8),
        headerPadding: const EdgeInsets.all(16),
        groupItemPadding: EdgeInsets.all(0),
        // groupPadding: const EdgeInsets.symmetric(horizontal: 4),
        groupBackgroundColor: HexColor.fromHex('#000000'),
        stretchGroupHeight: false,
      );
      return AppFlowyBoard(
        controller: controller,
        cardBuilder: (context, group, groupItem) {
          return AppFlowyGroupCard(
            key: ValueKey(groupItem.id),
            child: Container(
              decoration: BoxDecoration(
                color: HexColor.fromHex('#ffffff'),
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft, child: Text("Example text", style: TextStyle(color: Colors.black),)),
          );
        },
        boardScrollController: boardController,
        footerBuilder: (context, columnData) {
          return AppFlowyGroupFooter(
            icon: const Icon(Icons.add, size: 20),
            title: const Text('New'),
            height: 50,
            margin: const EdgeInsets.all(0),
            onAddButtonClick: () {
              print('onAddButtonClick');
              boardController.scrollToBottom(columnData.id);
            },
          );
        },
        headerBuilder: (context, columnData) {
          return AppFlowyGroupHeader(
            title: Expanded(child: TextField(
                controller: TextEditingController()
                  ..text = columnData.headerData.groupName,
                onSubmitted: (val) {
                  print('onSubmitted');
                  // controller
                  //     .getGroupController(columnData.headerData.groupId)!
                  //     .updateGroupName(val);
                },
            )),
            height: 80,
            margin: const EdgeInsets.all(0),
          );
        },
        groupConstraints: const BoxConstraints.tightFor(width: 300),
        config: config);
    });
  }
}

