import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:short_uuids/short_uuids.dart';

const localDBFile = 'database.toml';
const shortId = ShortUuid();


// '(A)' | '(B)' | '(C)' | '(D)' | '(E)' | '(F)' | '(G)' | '(H)' | '(I)' | '(J)' | string
var low = "(A)";
var medium = "(B)";
var high = "(C)";
var none = "";
const allPriority = ['', '(A)' , '(B)' , '(C)' , '(D)' , '(E)' , '(F)' , '(G)' , '(H)' , '(I)' , '(J)'];

class Todo extends AppFlowyGroupItem {
  String id = shortId.generate();
  bool isComplete = false;
  String priority = allPriority[0];
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
    Todo(
      text: 'has tag all',
      tags: ['all'],
      priority: allPriority[0]
    ),
    Todo(
      text: 'has tag todo',
      tags: ['todo'],
      priority: allPriority[0]
    ),
  ];
  List<KanbanGroup> columns = [
    KanbanGroup(id: 'all'),
    KanbanGroup(id: 'todo'),
    KanbanGroup(id: 'completed'),
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
