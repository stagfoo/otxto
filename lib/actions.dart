import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:core';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:oxtxto/style.dart';
import 'package:path/path.dart';
import 'package:toml/toml.dart';

import 'store.dart';
import 'storage.dart';

Future<void> handleSubmitNewTodo(GlobalState state, String text) async {
  var newTodo = importTodoTextLine(text);
  if (newTodo.text.isEmpty) {
    return;
  }
  if (newTodo.createdAt.isEmpty) {
    newTodo.createdAt = formatTimestamp(DateTime.now());
  }
  //FIXME i shouldn't use @unsorted, it should be tags that wrong exists in columns
  state.addNewTodo(newTodo);
  // saveToml(localDBFile, state);
}

Future<void> handleOnMoveGroupItemToGroup(
    GlobalState state, fromColumnName, id, toColumnName) async {
    var newTodos = state.todos;
    for (var element in newTodos) {
      if (element.id == id) {
        element.tags = element.tags.where((tag) => tag != fromColumnName).toList();
        element.tags = [...{toColumnName, ...element.tags}];
      }
    state.setTodos(newTodos);
  }
}


Future<void> handleOnClickNavbar(GlobalState state, String page,
    int navbarIndex, BuildContext context) async {
  switch (page) {
    case 'list':
      Get.toNamed('/list');
      break;
    case 'open':
      try {
        //TODO move to function
        //TODO Clear state when importing new file
        var file = await pickFile();
        state.setTodoFilePath(file.path);
        file.openRead().transform(utf8.decoder).listen((value) {
          var lines = value.split('\n');
          List<Todo> todoList = [];
          lines.forEach((element) {
             todoList.add(importTodoTextLine(element));
          });
          state.setTodos(todoList);
        });
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

saveToml(String name, GlobalState state) async {
  Map<String, dynamic> tomlTemplate = {'todos': state.todos};
  var tomlDB = TomlDocument.fromMap(tomlTemplate).toString();
  var file = File(localDBFile);
  file.writeAsString(tomlDB);
}

saveTodoText(GlobalState state) async {
  var file = File(state.todoFilePath);
  // get todos and convert to string and write to file
  var todos = state.todos;
  var todoText = todos.map((e) => createTodoTextLine(e.isComplete, e.text, e.priority, e.completedAt, e.createdAt, e.project, e.tags)).join('\n');
  file.writeAsString('', flush: true);
  file.writeAsString(todoText, flush: true);
}

loadToml(String name) async {
  //load toml
  var document = await TomlDocument.load(name);
  var documents = TomlDocument.parse(document.toString()).toMap();
  return documents;
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
      priority != null && priority.isNotEmpty ?  priority + ' ' : '';
  var hasCompletedAt = completedAt != null ? completedAt + ' ' : '';
  var hasCreatedAt = createdAt.isNotEmpty ? createdAt + ' ' : '';
  var hasText = text.isNotEmpty ? text + ' ' : '';
  var hasProject =
      project != null && project.isNotEmpty ? project + ' ' : '';
  var hasTags = tags != null ? tags.join(' ') : '';
  return (isComplete +
      hasPriority +
      hasCompletedAt +
      hasCreatedAt +
      hasText +
      hasProject +
      hasTags).replaceAll('  ', ' ');
}

Todo importTodoTextLine(String line) {

  var isPriority = RegExp(r'\([A-Z]\) ');
  var isComplete = RegExp(r'x ');
  var isDateLike = RegExp(r'\d{4}-\d{2}-\d{2}');
  var isProject = RegExp(r' \+[a-zA-Z0-9]+');
  var isTag = RegExp(r'@[a-zA-Z0-9]+');
  
 
  var complete = isComplete.hasMatch(line);
  var priority = isPriority.allMatches(line).map((e) => e.group(0).toString().trim());
  var project =  isProject.allMatches(line).map((e) => e.group(0).toString().trim());
  var dates =  isDateLike.allMatches(line).map((e) => e.group(0).toString().trim()).toList();
  var tags = isTag.allMatches(line).map((e) => e.group(0).toString().trim()).toList();
  var text =  line.replaceAll(isComplete, '').replaceAll(isPriority, '').replaceAll(isDateLike, '').replaceAll(isProject, '').replaceAll(isTag, '').trim();
  
  var nextTodoItem = Todo(text: text, tags: tags, priority: priority.isNotEmpty ? priority.first : '');
  nextTodoItem.completedAt = dates.length > 1 ? dates[1] : '';
  nextTodoItem.createdAt = dates.isNotEmpty ? dates[0] : '';
  nextTodoItem.project = project.isNotEmpty ? project.first : '';
  nextTodoItem.isComplete = complete;
  return nextTodoItem;
}

// Utility functions

String formatTimestamp(DateTime timestamp) {
  return "${timestamp.year.toString()}-${timestamp.month.toString().padLeft(2,'0')}-${timestamp.day.toString().padLeft(2,'0')}";
}

Color randomStringToHexColor(String string) {
  return HexColor.fromHex(getRandomColorClass(string));
}