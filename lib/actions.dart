import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'store.dart';
import 'middleware.dart';
import 'storage.dart';
import 'utils.dart';

Future<void> handleSubmitNewTodo(GlobalState state, String text) async {
  var newTodo = importTodoTextLine(text);
  if (newTodo.text.isEmpty) {
    return;
  }
  if (newTodo.createdAt.isEmpty) {
    newTodo.createdAt = formatTimestamp(DateTime.now());
  }
  var editingIndex = state.isEditing.status
      ? state.todos.indexWhere((t) => t.id == state.isEditing.id)
      : -1;
  if (editingIndex == -1) {
    state.addNewTodo(newTodo);
  } else {
    // Replace the edited todo in place so it keeps its position
    newTodo.id = state.isEditing.id;
    state.setTodos([...state.todos]..[editingIndex] = newTodo);
  }
  saveTodoText(state);
}

Future<void> handleCloseFolder(GlobalState state) async {
  saveTodoText(state);
  saveToml(state.settingsFilePath, state);
  if (state.todoFilePath == '') {
    // check all files persmission android
    await createDefaultFiles(state);
  }
  Get.toNamed('/open');
  state.setColumns([]);
  state.setTodos([]);
  state.setTodoFilePath('');
  state.setSettingsFilePath('');
}

/// Updates the tags / completion of [todo] so it belongs to [toColumnId].
void moveTodoToColumn(Todo todo, String fromColumnId, String toColumnId) {
  if (toColumnId == completedColumnId) {
    todo.isComplete = true;
  } else {
    todo.tags = todo.tags.where((tag) => tag != fromColumnId).toList();
  }
  if (!restrictedColumns.contains(toColumnId)) {
    todo.tags = [
      ...{toColumnId, ...todo.tags}
    ];
  }
  if (fromColumnId == completedColumnId) {
    todo.isComplete = false;
  }
}

/// Moves a todo into [toColumnId], placing it just above [beforeTodoId]
/// or at the bottom of the column when [beforeTodoId] is null.
///
/// Columns are views over the todo.txt file, so the order of the cards
/// is the order of the lines in the file.
void handleMoveTodo(
  GlobalState state, {
  required String todoId,
  required String fromColumnId,
  required String toColumnId,
  String? beforeTodoId,
}) {
  var todos = [...state.todos];
  var index = todos.indexWhere((t) => t.id == todoId);
  if (index == -1 || todoId == beforeTodoId) {
    return;
  }
  var todo = todos.removeAt(index);
  if (fromColumnId != toColumnId) {
    moveTodoToColumn(todo, fromColumnId, toColumnId);
  }

  var insertAt =
      beforeTodoId == null ? -1 : todos.indexWhere((t) => t.id == beforeTodoId);
  if (insertAt == -1) {
    var lastInColumn =
        todos.lastIndexWhere((t) => state.isInColumn(t, toColumnId));
    insertAt = lastInColumn == -1 ? todos.length : lastInColumn + 1;
  }
  todos.insert(insertAt, todo);
  state.setTodos(todos);
  saveTodoText(state);
}

void handleDeleteTodo(GlobalState state, String id) {
  state.removeTodo(id);
  saveTodoText(state);
}

void handleDeleteColumn(GlobalState state, String id) {
  state.setColumns(state.columns.where((element) => element.id != id).toList());
  saveToml(state.settingsFilePath, state);
}

void handleAddNewColumn(GlobalState state, String text) {
  text = text.trim();
  if (text.isEmpty) {
    return;
  }
  var name = (text.startsWith('@') ? text : '@' + text).toLowerCase();
  if (state.columns.any((c) => c.id == name)) {
    return;
  }
  state.addNewColumn(name);
  saveToml(state.settingsFilePath, state);
}

/// Creates an empty todo.txt and settings file in [rootFolder],
/// asking the user to pick a folder when none is given.
Future<void> createDefaultFiles(GlobalState state, [String? rootFolder]) async {
  rootFolder ??= await pickDir();
  if (rootFolder == null || rootFolder.isEmpty) {
    return;
  }
  var todoFile = File(p.join(rootFolder, 'todo.txt'));
  var settingsFile = File(p.join(rootFolder, localDBFile));
  if (!todoFile.existsSync()) {
    await todoFile.create(recursive: true);
  }
  if (!settingsFile.existsSync()) {
    await settingsFile.create(recursive: true);
  }
  state.setTodoFilePath(todoFile.path);
  state.setSettingsFilePath(settingsFile.path);
  await saveToml(state.settingsFilePath, state);
  await saveTodoText(state);
}

Future<void> handleOnClickNavbar(
    GlobalState state, String page, int navbarIndex) async {
  switch (page) {
    case 'list':
      Get.toNamed('/list');
      break;
    case 'create':
      try {
        await createDefaultFiles(state);
        Get.toNamed('/');
      } catch (err) {
        debugPrint('Failed to create files: $err');
      }
      break;
    case 'open':
      try {
        var rootFolder = await pickDir();
        if (rootFolder == null) {
          return;
        }
        await openFolder(state, rootFolder);
        Get.toNamed('/');
      } catch (err) {
        debugPrint('Failed to open: $err');
      }
      break;
    default:
      Get.toNamed('/');
  }
  state.saveNavbarIndex(navbarIndex);
}

/// Loads the todo.txt and settings file from [rootFolder],
/// creating whichever of them is missing.
Future<void> openFolder(GlobalState state, String rootFolder) async {
  var files = getFilesFromFolder(rootFolder);
  File? settingsFile;
  File? todoFile;
  for (var file in files) {
    var name = p.basename(file.path);
    if (name == localDBFile) {
      settingsFile = file;
    } else if (name == 'todo.txt' ||
        (todoFile == null && name.endsWith('.txt'))) {
      todoFile = file;
    }
  }
  if (settingsFile != null) {
    await loadSettingFile(state, settingsFile);
  }
  if (todoFile != null) {
    await loadTodoFile(state, todoFile);
  }
  if (settingsFile == null || todoFile == null) {
    await createDefaultFiles(state, rootFolder);
  }
}

Future<void> loadSettingFile(GlobalState state, File settingsFile) async {
  var value = await loadToml(settingsFile.path);
  var columns = List<String>.from(value['settings']?['columns'] ?? []);
  state.setColumns(columns.map((e) => KanbanGroup(id: e)).toList());
  state.setSettingsFilePath(settingsFile.path);
}

Future<void> loadTodoFile(GlobalState state, File file) async {
  var lines = await file.readAsLines();
  state.setTodoFilePath(file.path);
  state.setTodos(lines
      .where((line) => line.trim().isNotEmpty)
      .map(importTodoTextLine)
      .toList());
}

Future<void> saveTodoText(GlobalState state) async {
  if (state.todoFilePath.isEmpty) {
    return;
  }
  var todoText = state.todos.map(createTodoTextLine).join('\n');
  await File(state.todoFilePath).writeAsString(todoText, flush: true);
}
