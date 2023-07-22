// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/storage.dart';
import '../lib/store.dart';
import '../lib/utils.dart';
import '../lib/actions.dart';

void main() {
 test("[ACTION] Exporting a complete todo", () {
    Todo todo = Todo(
      text: 'example',
      tags: ['@todo'],
      priority: ''
    );
    todo.isComplete = true;
    String result = createTodoTextLine(todo);
    String text = 'x ${todo.createdAt} example @todo';
    expect(result, text);
  });

 test('[ACTION] Exporting a incomplete todo with a project', () {
    Todo todo = Todo(
      text: 'example',
      tags: ['@todo'],
      priority: ''
    );
    todo.isComplete = false;
    todo.project = '+otxto';
    String result = createTodoTextLine(todo).trim();
    String text = '${todo.createdAt} example +otxto @todo';
    expect(result, text);
  });
   test('[ACTION] Exporting a complete todo with a project, 2 tags and prority', () {
    Todo todo = Todo(
      text: 'example',
      tags: ['@todo', '@todo2'],
      priority: '(A)'
    );
    todo.isComplete = true;
    todo.project = '+otxto';
    String result = createTodoTextLine(todo);
    String text = 'x (A) ${todo.createdAt} example +otxto @todo @todo2';
    expect(result, text);
  });
}
