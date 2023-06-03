import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:toml/toml.dart';

import 'store.dart';
import 'storage.dart';

Future<void> handleSubmitNewTodo(GlobalState state, String text) async {
  var newTodo = Todo(text: text, tags: ['@all'], priority: '');
  state.addNewTodo(newTodo);
  print(createTodoTextLine(newTodo.isComplete, newTodo.text, newTodo.priority,
      newTodo.completedAt, newTodo.createdAt, newTodo.project, newTodo.tags));
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
    var newTodos = state.todos;
    for (var element in newTodos) {
      if (element.id == state.startedDragTarget) {
        if(fromColumnName == '@completed'){
          element.isComplete = false;
          element.completedAt = '';
        }
        if(toColumnName == '@completed'){
          element.isComplete = true;
          element.completedAt = formatTimestamp(DateTime.now());
        }
        print(createTodoTextLine(
        element.isComplete,
        element.text,
        element.priority,
        element.completedAt,
        element.createdAt,
        element.project,
        [toColumnName]));
        element.tags = [toColumnName];
      }
    }
    state.setTodos(newTodos);
    state.setStartedDragTarget('');
    state.setEndedDragTarget('');
  }
}

Future<void> handleOnClickNavbar(GlobalState state, String page,
    int navbarIndex, BuildContext context) async {
  switch (page) {
    case 'list':
      break;
    case 'open':
      try {
        var file = await pickFile();
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
  print(hasTags);
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
