import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:oxtxto/store.dart';
import 'package:oxtxto/ui.dart';
import 'package:oxtxto/utils.dart';

Future<GlobalState> pumpBoard(WidgetTester tester, List<String> lines) async {
  tester.binding.window.physicalSizeTestValue = const Size(1600, 1000);
  tester.binding.window.devicePixelRatioTestValue = 1;
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

  var state = GlobalState();
  state.setColumns([KanbanGroup(id: '@work')]);
  state.setTodos(lines.map(importTodoTextLine).toList());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(
      home: Consumer<GlobalState>(
          builder: (context, state, _) => HomePage(state: state)),
    ),
  ));
  return state;
}

Future<void> dragCard(WidgetTester tester, String from, Offset to,
    {bool longPress = false}) async {
  var gesture = await tester.startGesture(tester.getCenter(find.text(from)));
  if (longPress) {
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
  }
  // Move in small steps so the drag target sees the card moving
  var start = tester.getCenter(find.text(from));
  for (var i = 1; i <= 10; i++) {
    await gesture.moveTo(Offset.lerp(start, to, i / 10)!);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pumpAndSettle();
  await gesture.up();
  await tester.pumpAndSettle();
}

List<String> textsIn(GlobalState state, String columnId) =>
    state.todosInColumn(columnId).map((t) => t.text).toList();

final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

void main() {
  testWidgets('dragging a card above another reorders the column',
      (tester) async {
    var state = await pumpBoard(tester, ['first @work', 'second @work']);
    await dragCard(tester, 'second', tester.getCenter(find.text('first')));
    expect(textsIn(state, '@work'), ['second', 'first']);
  }, variant: desktop);

  testWidgets('dragging a card to another column moves it', (tester) async {
    var state = await pumpBoard(tester, ['untagged', 'first @work']);
    var target = tester.getBottomLeft(find.text('first'));
    await dragCard(tester, 'untagged', target + const Offset(20, 40));
    expect(textsIn(state, allColumnId), isEmpty);
    expect(textsIn(state, '@work'), ['first', 'untagged']);
  }, variant: desktop);

  testWidgets('cards are dragged with a long press on touch screens',
      (tester) async {
    var state = await pumpBoard(tester, ['first @work', 'second @work']);
    await dragCard(tester, 'second', tester.getCenter(find.text('first')),
        longPress: true);
    expect(textsIn(state, '@work'), ['second', 'first']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('a gap opens where the card will land', (tester) async {
    await pumpBoard(tester, ['first @work', 'second @work']);
    var first = tester.getCenter(find.text('first'));
    var gesture =
        await tester.startGesture(tester.getCenter(find.text('second')));
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();
    await gesture.moveTo(first);
    await tester.pump();
    // "first" slides down smoothly to make room for the dragged card
    await tester.pump(const Duration(milliseconds: 100));
    var halfway = tester.getCenter(find.text('first')).dy;
    await tester.pumpAndSettle();
    var settled = tester.getCenter(find.text('first')).dy;
    expect(halfway, greaterThan(first.dy));
    expect(settled, greaterThan(halfway));
    await gesture.up();
    await tester.pumpAndSettle();
  }, variant: desktop);
}
