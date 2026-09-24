import 'package:flutter/material.dart';

import 'actions.dart';
import 'molecules/todo_card.dart';
import 'organisms/todo_list.dart';
import 'store.dart';
import 'style.dart';

const _inputBorder =
    OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2));

//------------------------PAGE----------------------------
final addNewTodoController = TextEditingController();

class HomePage extends StatelessWidget {
  final GlobalState state;
  const HomePage({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: DeleteTarget(state: state),
        body: Padding(
            padding: const EdgeInsets.only(top: 40, left: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
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
                      enabledBorder: _inputBorder,
                      border: _inputBorder),
                )),
                Container(
                    decoration: BoxDecoration(
                      color: randomStringToHexColor('uu'),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
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
              const SizedBox(height: 16),
              Expanded(child: KanbanView(state: state))
            ])));
  }
}

/// Drop a card here to delete it.
class DeleteTarget extends StatelessWidget {
  final GlobalState state;
  const DeleteTarget({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<TodoDragData>(
      builder: (context, candidateItems, rejectedItems) {
        var isHovered = candidateItems.isNotEmpty;
        return AnimatedScale(
          scale: isHovered ? 1.2 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isHovered ? Colors.redAccent : randomStringToHexColor('uu'),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            padding: const EdgeInsets.all(16),
            child: const Tooltip(
                message: "Drag a card here to delete",
                child: Icon(
                  Icons.delete,
                  color: Colors.black,
                )),
          ),
        );
      },
      onAccept: (data) {
        handleDeleteTodo(state, data.todo.id);
      },
    );
  }
}

class OpenPage extends StatelessWidget {
  final GlobalState state;
  const OpenPage({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 240,
            margin: const EdgeInsets.only(bottom: 32),
            child: const Image(image: AssetImage('assets/logo.png')),
          ),
          _OpenPageButton(
            icon: Icons.folder_outlined,
            label: "Open Folder",
            onPressed: () => handleOnClickNavbar(state, 'open', 0),
          ),
          const SizedBox(height: 16),
          _OpenPageButton(
            icon: Icons.new_releases,
            label: "new todo file",
            onPressed: () => handleOnClickNavbar(state, 'create', 0),
          ),
          //TODO add recently opened
          // but this is handled by most OSs so probably not that useful
        ])));
  }
}

class _OpenPageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _OpenPageButton(
      {Key? key,
      required this.icon,
      required this.label,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          side: MaterialStateProperty.all(
              const BorderSide(width: 1, color: Colors.white)),
          backgroundColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.purpleAccent;
            }
            return Colors.black;
          })),
      onPressed: onPressed,
      child: SizedBox(
          width: 240,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(icon, color: Colors.white),
                  ),
                  Text(label, style: const TextStyle(color: Colors.white)),
                ],
              ))),
    );
  }
}

class KanbanView extends StatelessWidget {
  final GlobalState state;
  const KanbanView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var columnIds = [
      allColumnId,
      ...state.columns.map((column) => column.id),
      completedColumnId,
    ];
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (var columnId in columnIds)
          TodoColumn(key: ValueKey(columnId), columnId: columnId, state: state),
        AddNewColumn(state: state)
      ],
    );
  }
}

class TodoColumn extends StatelessWidget {
  final String columnId;
  final GlobalState state;
  const TodoColumn({Key? key, required this.columnId, required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SizedBox(
            width: cardWidth,
            child: Column(children: [
              ColumnTitle(text: columnId, state: state),
              Expanded(
                  child: TodoList(
                      state: state,
                      list: state.todosInColumn(columnId),
                      columnId: columnId,
                      addNewTodoController: addNewTodoController))
            ])));
  }
}

class AddNewColumn extends StatefulWidget {
  final GlobalState state;
  const AddNewColumn({Key? key, required this.state}) : super(key: key);

  @override
  State<AddNewColumn> createState() => _AddNewColumnState();
}

class _AddNewColumnState extends State<AddNewColumn> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
            width: cardWidth,
            height: 48,
            child: TextFormField(
                controller: textController,
                maxLines: 1,
                onFieldSubmitted: (text) {
                  handleAddNewColumn(widget.state, text);
                  textController.clear();
                },
                decoration: const InputDecoration(
                    hintText: 'Add @tag column',
                    prefixIcon: Icon(Icons.view_kanban_outlined),
                    enabledBorder: _inputBorder,
                    border: _inputBorder))));
  }
}

//Move to Molecules
class ColumnTitle extends StatelessWidget {
  final String text;
  final GlobalState state;
  const ColumnTitle({Key? key, required this.text, required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRestrictedColumn = restrictedColumns.contains(text);
    Color bgColor =
        isRestrictedColumn ? Colors.black : randomStringToHexColor(text);
    Color textColor = contrastingTextColor(bgColor);
    return Container(
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Colors.white, width: 2)),
        margin: const EdgeInsets.only(bottom: 8),
        height: 52,
        child: Row(children: [
          Expanded(
              child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          )),
          if (!isRestrictedColumn)
            IconButton(
                iconSize: 20,
                color: textColor,
                tooltip: 'Remove column',
                onPressed: () {
                  handleDeleteColumn(state, text);
                },
                icon: const Icon(Icons.close))
        ]));
  }
}
