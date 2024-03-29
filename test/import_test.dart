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
  test('[Import] Basic Example of todo', () {
    String line = 'x 2023-06-15 example @todo +otxto';
    Todo result = importTodoTextLine(line);
    expect(result.isComplete, equals(true));
    expect(result.text, equals("example"));
    expect(result.createdAt, equals("2023-06-15"));
    expect(result.project, equals("+otxto"));
    expect(result.tags, equals(["@todo"]));
  });

  test('[Import] Project Symbols in the text', () {
    String line = 'x 2023-06-15 change the + to a - in the UI @todo +otxto';
    Todo result = importTodoTextLine(line);
    expect(result.isComplete, equals(true));
    expect(result.text, equals("change the + to a - in the UI"));
    expect(result.createdAt, equals("2023-06-15"));
    expect(result.project, equals("+otxto"));
    expect(result.tags, equals(["@todo"]));
  });

  test('[Import] Tag Symbols in the text', () {
    String line = 'x 2023-06-15 change the @ to a + in the UI @todo +otxto';
    Todo result = importTodoTextLine(line);
    expect(result.isComplete, equals(true));
    expect(result.text, equals("change the @ to a + in the UI"));
    expect(result.createdAt, equals("2023-06-15"));
    expect(result.project, equals("+otxto"));
    expect(result.tags, equals(["@todo"]));
  });

  test('[Import] Start & Complete Date', () {
    String line =
        'x 2023-06-15 2023-06-16 change the @ to a + in the UI @todo +otxto';
    Todo result = importTodoTextLine(line);
    expect(result.isComplete, equals(true));
    expect(result.text, equals("change the @ to a + in the UI"));
    expect(result.createdAt, equals("2023-06-15"));
    expect(result.project, equals("+otxto"));
    expect(result.tags, equals(["@todo"]));
  });

  test('[Import] Tags with numbers', () {
    String line = 'x example @todo1 @todo2';
    Todo result = importTodoTextLine(line);
    expect(result.tags, equals(["@todo1", "@todo2"]));
  });
  test('[Import] Tags with underscores', () {
    String line = 'x example @todo_1 @todo_2';
    Todo result = importTodoTextLine(line);
    expect(result.tags, equals(["@todo_1", "@todo_2"]));
  });
}
