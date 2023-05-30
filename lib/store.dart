import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:short_uuids/short_uuids.dart';

import 'example.dart';

const localDBFile = 'database.toml';
const shortId = ShortUuid();


// '(A)' | '(B)' | '(C)' | '(D)' | '(E)' | '(F)' | '(G)' | '(H)' | '(I)' | '(J)' | string
var low = "(A)";
var medium = "(B)";
var high = "(C)";
var none = "";
enum Priority { low, medium, high, none }

class Todo {
  String id = shortId.generate();
  bool isComplete = false;
  Priority priority = Priority.none;
  String completedAt = '';
  String createdAt = DateTime.now().toString();
  String text;
  String project = '';
  List<String> tags = [];
  List<String> spec = [];
  Todo({
    required this.text
  });
}

class KanbanGroup {
  String id;
  KanbanGroup({required this.id});
  
}

class GlobalState extends ChangeNotifier {
  int currentNavbarIndex = 0;
  List<Todo> todos = [];
  List<KanbanGroup> columns = [];
  late Todo selectedItem;
  late String todoFilePath;

  void addNewTodo(Todo todo) {
    todos.add(todo);
    notifyListeners();
  }
  void setTodos(List<Todo> value) {
    todos = value;
    notifyListeners();
  }

  void saveNavbarIndex(int value) {
    currentNavbarIndex = value;
    notifyListeners();
  }
}
