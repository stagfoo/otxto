import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:toml/toml.dart';

import 'store.dart';

Future<void> handleSubmitNewTodo(GlobalState state, String text) async {
  var newTodo = Todo(text: text, tags: ['all'], priority: allPriority[0]);
  state.addNewTodo(newTodo);
  print(createTodoTextLine(newTodo.isComplete, newTodo.text, newTodo.priority, newTodo.completedAt, newTodo.createdAt, newTodo.project, newTodo.tags));
  // saveToml(localDBFile, state);
}

Future<void> handleOnMoveGroupItem(
    GlobalState state, columnName, fromIndex, toIndex) async {
  if (state.startedDragTarget == state.endedDragTarget) {
    debugPrint('Please update');
  }
}

Future<void> handleOnMoveGroupItemToGroup(
    GlobalState state, fromColumnName, fromIndex, toColumnName, toIndex) async {
  debugPrint(state.startedDragTarget);
  debugPrint(state.endedDragTarget);
  if (state.startedDragTarget.toString() == state.endedDragTarget.toString()) {
    debugPrint('doing map');
    var newTodos = state.todos;
    for (var element in newTodos) {
      if (element.id == state.startedDragTarget) {
        element.tags = [toColumnName];
      }
    }
    state.setTodos(newTodos);
    state.setStartedDragTarget('');
    state.setEndedDragTarget('');
  }
}

Future<void> navigateToPage(GlobalState state, String page, int navbarIndex,
    BuildContext context) async {
  switch (page) {
    case 'other':
      Get.toNamed('/other-page');
      // Download shark json
      break;
    default:
      Get.toNamed('/');
  }
  state.saveNavbarIndex(navbarIndex);
}

saveToml(String name, GlobalState state) async {
  Map<String, dynamic> tomlTemplate = {'todos': state.todos};
  var tomlDB = TomlDocument.fromMap(tomlTemplate).toString();
  var file = File(localDBFile);
  file.writeAsString(tomlDB);
}

loadToml(String name) async {
  //load toml
  var document = await TomlDocument.load(name);
  var documents = TomlDocument.parse(document.toString()).toMap();
  return documents;
}

createTodoTextLine(bool complete, String text, String? priority, String? completedAt, String createdAt, String? project, List<String>? tags) {
	var isComplete = complete ? 'x ' : '';
  var hasPriority = priority != null && priority.isNotEmpty ? '(' + priority + ') ' : '';
  var hasCompletedAt = completedAt != null ? completedAt + ' ' : '';
  var hasCreatedAt = createdAt.isNotEmpty ? createdAt + ' ' : '';
  var hasText = text.isNotEmpty ? text + ' ' : '';
  var hasProject = project != null && project.isNotEmpty ? '+' + project + ' ' : '';
  var hasTags = tags != null ? tags.join(' ') : '';
  return isComplete + hasPriority + hasCompletedAt + hasCreatedAt + hasText + hasProject + hasTags;
}