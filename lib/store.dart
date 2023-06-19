import 'package:flutter/material.dart';
import 'package:short_uuids/short_uuids.dart';

import 'utils.dart';

const localDBFile = 'otxto-settings.toml';
const shortId = ShortUuid();
const restrictedColumns = ['all', 'completed'];

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
    return createTodoTextLine(this);
  }
}

class KanbanGroup {
  String id;
  KanbanGroup({required this.id});
}

class EditingState {
  bool status = false;
  late String id;
  EditingState({
    required this.status,
    required this.id,
  });
}

class GlobalState extends ChangeNotifier {
  int currentNavbarIndex = 0;
  List<Todo> todos = [];
  List<KanbanGroup> columns = [];
  late Todo selectedItem;
  late String todoFilePath = '';
  late String settingsFilePath = '';
  EditingState isEditing = EditingState(status: false, id: '');

  void setTodoFilePath(String path) {
    todoFilePath = path;
    notifyListeners();
  }

  void setSettingsFilePath(String path) {
    settingsFilePath = path;
    notifyListeners();
  }

  void addNewTodo(Todo todo) {
    todos.add(todo);
    notifyListeners();
  }

  void removeTodo(String id) {
    setTodos(todos.where((element) => element.id != id).toList());
    notifyListeners();
  }

  void setEditingStatus(String id, bool status) {
    isEditing = EditingState(status: status, id: id);
    notifyListeners();
  }

  void addNewColumn(String id) {
    columns.add(KanbanGroup(id: id));
    notifyListeners();
  }

  void setTodos(List<Todo> value) {
    todos = value;
    notifyListeners();
  }

  void setColumns(List<KanbanGroup> value) {
    columns = value;
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
