import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:oxtxto/style.dart';

import 'store.dart';
import 'storage.dart';

Future<void> handleSubmitNewTodo(GlobalState state, String text) async {
  if (state.isEditing.status) {
    state.removeTodo(state.isEditing.id);
  }
  var newTodo = importTodoTextLine(text);
  if (newTodo.text.isEmpty) {
    return;
  }
  if (newTodo.createdAt.isEmpty) {
    newTodo.createdAt = formatTimestamp(DateTime.now());
  }
  state.addNewTodo(newTodo);
  // saveToml(localDBFile, state);
}

Future<void> handleOnMoveGroupItemToGroup(
    GlobalState state, fromColumnName, id, toColumnName) async {
  var newTodos = state.todos;
  for (var element in newTodos) {
    if (element.id == id) {
      //TODO refactor this
      if (toColumnName == 'completed') {
        element.isComplete = true;
      } else {
        element.tags =
            element.tags.where((tag) => tag != fromColumnName).toList();
      }
      if (!restrictedColumns.contains(toColumnName)) {
        element.tags = [
          ...{toColumnName, ...element.tags}
        ];
      }

      if (fromColumnName == 'completed') {
        element.isComplete = false;
      }
    }
    state.setTodos(newTodos);
  }
}

void handleDeleteTodo(GlobalState state, id) async {
  var newTodos = state.todos;
  state.setTodos(newTodos.where((element) => element.id != id).toList());
}

void handleDeleteColumn(GlobalState state, id) async {
  var columns = state.columns;
  state.setColumns(columns.where((element) => element.id != id).toList());
}

Future<void> handleOnClickNavbar(GlobalState state, String page,
    int navbarIndex, BuildContext context) async {
  switch (page) {
    case 'list':
      Get.toNamed('/list');
      break;
    case 'open':
      try {
        //Refactor with macos permission?
        // Create a dialog for errors to open
        var rootFolder = await pickDir();
        var files = await getFilesFromFolder(rootFolder!);
        loadSettingFile(state,
            files.where((element) => element.path.contains(localDBFile)).first);
        loadTodoFile(state,
            files.where((element) => element.path.contains('.txt')).first);
      } catch (err) {
        // print(err);
      }
      break;
    default:
      print('page: ' + page);
      Get.toNamed('/');
  }
  state.saveNavbarIndex(navbarIndex);
}

loadSettingFile(GlobalState state, File settingsFile) async {
  loadToml(settingsFile.path).then((value) {
    List<String> columns = List<String>.from((value['settings']['columns']));
    state.setColumns(columns.map((e) => KanbanGroup(id: e)).toList());
    state.setSettingsFilePath(settingsFile.path);
  });
}

loadTodoFile(GlobalState state, File file) async {
  state.setTodoFilePath(file.path);

  file.openRead().transform(utf8.decoder).listen((value) {
    var lines = value.split('\n');
    List<Todo> todoList = [];
    for (var element in lines) {
      todoList.add(importTodoTextLine(element));
    }
    state.setTodos(todoList);
  });
}

Future<List<dynamic>> getFilesFromFolder(String root) async {
  try {
    var list = [];
    List<FileSystemEntity> contents = Directory(root).listSync();
    for (var fileOrDir in contents) {
      print(fileOrDir);
      if (fileOrDir is File) {
        list.add(fileOrDir);
      }
    }
    return list;
  } catch (err) {
    print("Get Files from folder failed or canceled");
    rethrow;
  }
}

Future<String?> pickDir() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    return '';
  }
  return selectedDirectory;
}

saveTodoText(GlobalState state) async {
  var file = File(state.todoFilePath);
  // get todos and convert to string and write to file
  var todos = state.todos;
  var todoText = todos
      .map((e) => createTodoTextLine(e.isComplete, e.text, e.priority,
          e.completedAt, e.createdAt, e.project, e.tags))
      .join('\n');
  file.writeAsString('', flush: true);
  file.writeAsString(todoText, flush: true);
}

//TODO refactor to Todo
String createTodoTextLine(
    bool complete,
    String text,
    String? priority,
    String? completedAt,
    String createdAt,
    String? project,
    List<String>? tags) {
  var isComplete = complete ? 'x ' : '';
  var hasPriority =
      priority != null && priority.isNotEmpty ? priority + ' ' : '';
  var hasCompletedAt = completedAt != null ? completedAt + ' ' : '';
  var hasCreatedAt = createdAt.isNotEmpty ? createdAt + ' ' : '';
  var hasText = text.isNotEmpty ? text + ' ' : '';
  var hasProject =
      project != null && project.isNotEmpty ? '+' + project + ' ' : '';
  var hasTags = tags != null ? tags.join(' ') : '';
  // Change columns from tags to select keys
  //column:doing
  return (isComplete +
          hasPriority +
          hasCompletedAt +
          hasCreatedAt +
          hasText +
          hasProject +
          hasTags)
      .replaceAll('  ', ' ');
}

Todo importTodoTextLine(String line) {
  var isPriority = RegExp(r'\([A-Z]\) ');
  var isComplete = RegExp(r'x ');
  var isDateLike = RegExp(r'\d{4}-\d{2}-\d{2}');
  var isProject = RegExp(r' \+[a-z0-9]+');
  var isTag = RegExp(r'@[a-z]+(-?[a-z]+)');

  var complete = isComplete.hasMatch(line);
  var priority =
      isPriority.allMatches(line).map((e) => e.group(0).toString().trim());
  var project =
      isProject.allMatches(line).map((e) => e.group(0).toString().trim());
  var dates = isDateLike
      .allMatches(line)
      .map((e) => e.group(0).toString().trim())
      .toList();
  var tags =
      isTag.allMatches(line).map((e) => e.group(0).toString().trim()).toList();
  var text = line
      .replaceAll(isComplete, '')
      .replaceAll(isPriority, '')
      .replaceAll(isDateLike, '')
      .replaceAll(isProject, '')
      .replaceAll(isTag, '')
      .trim();

  var nextTodoItem = Todo(
      text: text,
      tags: tags,
      priority: priority.isNotEmpty ? priority.first : '');
  nextTodoItem.completedAt = dates.length > 1 ? dates[1] : '';
  nextTodoItem.createdAt = dates.isNotEmpty ? dates[0] : '';
  nextTodoItem.project =
      project.isNotEmpty ? project.first.replaceAll('+', '') : '';
  nextTodoItem.isComplete = complete;
  return nextTodoItem;
}

// Utility functions

String formatTimestamp(DateTime timestamp) {
  return "${timestamp.year.toString()}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
}

Color randomStringToHexColor(String string) {
  return HexColor.fromHex(getRandomColorClass(string));
}
