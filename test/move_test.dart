import 'package:flutter_test/flutter_test.dart';

import 'package:oxtxto/actions.dart';
import 'package:oxtxto/store.dart';
import 'package:oxtxto/utils.dart';

GlobalState createState(List<String> lines, List<String> columns) {
  var state = GlobalState();
  state.setColumns(columns.map((id) => KanbanGroup(id: id)).toList());
  state.setTodos(lines.map(importTodoTextLine).toList());
  return state;
}

String idOf(GlobalState state, String text) =>
    state.todos.firstWhere((t) => t.text == text).id;

List<String> textsIn(GlobalState state, String columnId) =>
    state.todosInColumn(columnId).map((t) => t.text).toList();

void main() {
  test('[Move] Reorder a card up within a column', () {
    var state = createState(['a @work', 'b @work', 'c @work'], ['@work']);
    handleMoveTodo(state,
        todoId: idOf(state, 'c'),
        fromColumnId: '@work',
        toColumnId: '@work',
        beforeTodoId: idOf(state, 'a'));
    expect(textsIn(state, '@work'), ['c', 'a', 'b']);
  });

  test('[Move] Reorder a card to the bottom of a column', () {
    var state = createState(['a @work', 'b @work', 'c @work'], ['@work']);
    handleMoveTodo(state,
        todoId: idOf(state, 'a'), fromColumnId: '@work', toColumnId: '@work');
    expect(textsIn(state, '@work'), ['b', 'c', 'a']);
  });

  test('[Move] Move a card into the middle of another column', () {
    var state =
        createState(['a @home', 'b @work', 'c @work'], ['@home', '@work']);
    handleMoveTodo(state,
        todoId: idOf(state, 'a'),
        fromColumnId: '@home',
        toColumnId: '@work',
        beforeTodoId: idOf(state, 'c'));
    expect(textsIn(state, '@home'), isEmpty);
    expect(textsIn(state, '@work'), ['b', 'a', 'c']);
    expect(state.todos.firstWhere((t) => t.text == 'a').tags, ['@work']);
  });

  test('[Move] Drop at the bottom of a column keeps other columns in order',
      () {
    var state = createState(
        ['a @work', 'b @home', 'c @work', 'd @home'], ['@home', '@work']);
    handleMoveTodo(state,
        todoId: idOf(state, 'd'), fromColumnId: '@home', toColumnId: '@work');
    expect(textsIn(state, '@work'), ['a', 'c', 'd']);
    expect(state.todos.map((t) => t.text), ['a', 'b', 'c', 'd']);
  });

  test('[Move] Move a card into completed and back', () {
    var state = createState(['a', 'b @work'], ['@work']);
    handleMoveTodo(state,
        todoId: idOf(state, 'a'),
        fromColumnId: allColumnId,
        toColumnId: completedColumnId);
    expect(textsIn(state, completedColumnId), ['a']);
    handleMoveTodo(state,
        todoId: idOf(state, 'a'),
        fromColumnId: completedColumnId,
        toColumnId: '@work');
    expect(textsIn(state, completedColumnId), isEmpty);
    expect(textsIn(state, '@work'), ['b', 'a']);
  });
}
