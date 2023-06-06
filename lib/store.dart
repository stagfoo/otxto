import 'package:flutter/material.dart';
import 'package:oxtxto/ui.dart';
import 'package:short_uuids/short_uuids.dart';

import 'actions.dart';

const localDBFile = 'database.toml';
const shortId = ShortUuid();

class Todo {
  String id = shortId.generate();
  bool isComplete = false;
  String priority = '';
  String completedAt = '';
  String createdAt = formatTimestamp(DateTime.now());
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
  ];
  List<KanbanGroup> columns = [
    KanbanGroup(id: '@unsorted'),
    KanbanGroup(id: '@doing'),
    KanbanGroup(id: '@completed'),
  ];
  late Todo selectedItem;
  late String todoFilePath;

  void setTodoFilePath(String path) {
    todoFilePath = path;
    notifyListeners();
  }

  void addNewTodo(Todo todo) {
    todos.add(todo);
    notifyListeners();
    saveTodoText(this);
  }
  void addNewColumn(String id) {
    columns.add(KanbanGroup(id: id));
    notifyListeners();
  }

  void setTodos(List<Todo> value) {
    todos = value;
    notifyListeners();
    saveTodoText(this);
  }

  void updateTags(int index, List<String> tags) {
    todos[index].tags = tags;
    notifyListeners();
    saveTodoText(this);
  }

  void saveNavbarIndex(int value) {
    currentNavbarIndex = value;
    notifyListeners();
  }
}
