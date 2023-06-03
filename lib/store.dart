import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:short_uuids/short_uuids.dart';

import 'actions.dart';

const localDBFile = 'database.toml';
const shortId = ShortUuid();

class Todo extends AppFlowyGroupItem {
  String id = shortId.generate();
  bool isComplete = false;
  String priority = '';
  String completedAt = '';
  String createdAt = DateTime.now().toString();
  String text;
  String project = '';
  List<String> tags = [];
  List<String> spec = [];
  Todo({
    required this.text,
    required this.tags,
    required this.priority,
  });
  @override
  String toString() {
    //TODO set up todo.txt serialization
    return text;
  }
}

class KanbanGroup {
  String id;
  KanbanGroup({required this.id});
}

class GlobalState extends ChangeNotifier {
  int currentNavbarIndex = 0;
  List<Todo> todos = [
    Todo(text: 'Testing', tags: ['@unsorted'], priority: '')
  ];
  List<KanbanGroup> columns = [
    KanbanGroup(id: '@unsorted'),
    KanbanGroup(id: '@completed'),
  ];
  late Todo selectedItem;
  late String todoFilePath;
  String startedDragTarget = '';
  String endedDragTarget = '';

  void setStartedDragTarget(String value) {
    startedDragTarget = value;
  }

  void setEndedDragTarget(String value) {
    endedDragTarget = value;
  }

  void addNewTodo(Todo todo) {
    todos.add(todo);
    notifyListeners();
  }

  void setTodos(List<Todo> value) {
    todos = value;
    notifyListeners();
  }

  void updateTags(int index, List<String> tags) {
    todos[index].tags = tags;
    notifyListeners();
  }

  void saveNavbarIndex(int value) {
    currentNavbarIndex = value;
    notifyListeners();
  }
}
