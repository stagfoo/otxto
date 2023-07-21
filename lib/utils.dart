import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'store.dart';
import 'middleware.dart';
import 'storage.dart';

Todo importTodoTextLine(String line) {
  var isPriority = RegExp(r'\([A-Z]\) ');
  var isComplete = RegExp(r'^x ');
  var isDateLike = RegExp(r'\d{4}-\d{2}-\d{2}');
  var isProject = RegExp(r'\+[a-z0-9_]+');
  var isTag = RegExp(r'@[a-z]+(-?[a-z0-9_]+)');

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
      project.isNotEmpty ? project.first : '';
  nextTodoItem.isComplete = complete;
  return nextTodoItem;
}

String createTodoTextLine(Todo todo) {

  var isComplete = todo.isComplete ? 'x ' : '';
  var hasPriority =
      todo.priority != null && todo.priority.isNotEmpty ? todo.priority + ' ' : '';
  var hasCompletedAt = todo.completedAt != null ?  todo.completedAt + ' ' : '';
  var hasCreatedAt = todo.createdAt.isNotEmpty ? todo.createdAt + ' ' : '';
  var hasText = todo.text.isNotEmpty ? todo.text + ' ' : '';
  var hasProject =
      todo.project != null && todo.project.isNotEmpty ? todo.project + ' ' : '';
  var hasTags = todo.tags != null ? todo.tags.join(' ') : '';
  return (isComplete +
          hasPriority +
          hasCompletedAt +
          hasCreatedAt +
          hasText +
          hasProject +
          hasTags)
      .replaceAll('  ', ' ');
}



String formatTimestamp(DateTime timestamp) {
  return "${timestamp.year.toString()}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
}
