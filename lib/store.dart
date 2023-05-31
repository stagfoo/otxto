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

enum Priority { low, medium, high, none }

class Todo extends AppFlowyGroupItem {
  String id = shortId.generate();
  bool isComplete = false;
  Priority priority = Priority.none;
  String completedAt = '';
  String createdAt = DateTime.now().toString();
  String text;
  String project = '';
  List<String> tags = [];
  List<String> spec = [];
  Todo({required this.text, required this.tags});
  @override
  String toString() {
    //TODO set up todo.txt serialization
    return text;
  }
}

class KanbanGroup {
  String id;
  List<Todo> childern = [];
  KanbanGroup({required this.id, required this.childern});
}

class GlobalState extends ChangeNotifier {
  int currentNavbarIndex = 0;
  List<Todo> todos = [];
  List<KanbanGroup> columns = [
    KanbanGroup(id: 'all', childern: []),
    KanbanGroup(id: 'todo', childern: []),
  ];
  late Todo selectedItem;
  late String todoFilePath;

  void addNewTodo(String tag, Todo todo) {
    int index = columns.indexWhere((element) => element.id == tag);
    if(index > -1){
      columns[index].childern.add(todo);
      notifyListeners();
    }
  }

  void setTodos(List<Todo> value) {
    todos = value;
    notifyListeners();
  }

  void updateTags(String fromTag, int fromIndex, String toTag) {
    int fromTagIndex = columns.indexWhere((element) => element.id == fromTag);
    int toTagIndex = columns.indexWhere((element) => element.id == toTag);
    if(fromTagIndex > -1 && fromIndex > -1){
      var movedTodo = columns[fromTagIndex].childern[fromIndex];
      columns[fromTagIndex].childern.removeAt(fromIndex);
      columns[toTagIndex].childern.add(movedTodo);
      debugPrint('Move $fromTag:$fromIndex to $toTag:$toTagIndex');
      notifyListeners();
    }
  }

  void saveNavbarIndex(int value) {
    currentNavbarIndex = value;
    notifyListeners();
  }
}
