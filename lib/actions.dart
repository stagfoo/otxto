import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:oxtxto/style.dart';

import 'store.dart';
import 'middleware.dart';
import 'storage.dart';
import 'utils.dart';

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
  saveTodoText(state);
}

createTodoFile(GlobalState state) {}
createSettingsFile(GlobalState state) {}

Future<void> handleCloseFolder(GlobalState state) async {
  saveTodoText(state);
  saveToml(state.settingsFilePath, state);
  if (state.todoFilePath == '') {
    //Split into 2 functions
    // check all files persmission android
    createDefaultFiles(state);
  }
  Get.toNamed('/open');
  state.setColumns([]);
  state.setTodos([]);
  state.setTodoFilePath('');
  state.setSettingsFilePath('');
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
  saveTodoText(state);
}

void handleDeleteTodo(GlobalState state, id) async {
  var newTodos = state.todos;
  state.setTodos(newTodos.where((element) => element.id != id).toList());
  saveTodoText(state);
}

void handleDeleteColumn(GlobalState state, id) async {
  var columns = state.columns;
  state.setColumns(columns.where((element) => element.id != id).toList());
  saveToml(state.settingsFilePath, state);
}
void handleAddNewColumn(GlobalState state, String text) async {
  var name = text[0] == '@' ? text : '@' + text;
  state.addNewColumn(name.toLowerCase());
  saveToml(state.settingsFilePath, state);
}

void createDefaultFiles(GlobalState state) async {
  var rootFolder = await pickDir();
  //TODO add permission dialog
  state.setTodoFilePath(rootFolder!);
  state.setSettingsFilePath(rootFolder);
  saveToml(rootFolder + '/' + state.settingsFilePath, state);
  saveTodoText(state);
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
        if (files.isNotEmpty) {
          loadSettingFile(
              state,
              files
                  .where((element) => element.path.contains(localDBFile))
                  .first);
          loadTodoFile(state,
              files.where((element) => element.path.contains('.txt')).first);
        } else {
          createDefaultFiles(state);
        }
        Get.toNamed('/');
      } catch (err) {
        print(err);
        debugPrint("Failed to open");
      }
      break;
    default:
      Get.toNamed('/');
  }
  state.saveNavbarIndex(navbarIndex);
}

loadSettingFile(GlobalState state, File settingsFile) async {
  if (settingsFile.path.isEmpty) {
    print('misisng text file');
    return;
  }
  loadToml(settingsFile.path).then((value) {
    List<String> columns = List<String>.from((value['settings']['columns']));
    state.setColumns(columns.map((e) => KanbanGroup(id: e)).toList());
    state.setSettingsFilePath(settingsFile.path);
  });
}

loadTodoFile(GlobalState state, File file) async {
  if (file.path.isEmpty) {
    debugPrint('misisng text file');
    return;
  }
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

saveTodoText(GlobalState state) async {
  var file = File(state.todoFilePath);
  var todos = state.todos;
  var todoText = todos
      .map((e) => createTodoTextLine(e))
      .join('\n');
  file.writeAsString('', flush: true);
  file.writeAsString(todoText, flush: true);
}
