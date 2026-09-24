import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../actions.dart';
import '../store.dart';
import '../molecules/todo_card.dart';

const _cardSpacing = 8.0;
const _animationDuration = Duration(milliseconds: 200);
const _animationCurve = Curves.easeOutCubic;

/// What a card carries while it's being dragged.
class TodoDragData {
  final Todo todo;
  final String fromColumnId;

  /// Height of the card, used to size the gap it will drop into.
  double height = 0;

  /// Where the card was grabbed, relative to its top left corner.
  Offset grabOffset = Offset.zero;
  TodoDragData({required this.todo, required this.fromColumnId});
}

/// A column of cards which can be dragged to reorder them
/// or dropped into another column.
///
/// While a card is dragged over the column, a gap opens up where it
/// will land and the other cards slide out of the way.
class TodoList extends StatefulWidget {
  final String columnId;
  final List<Todo> list;
  final GlobalState state;
  final TextEditingController addNewTodoController;
  const TodoList(
      {Key? key,
      required this.columnId,
      required this.list,
      required this.state,
      required this.addNewTodoController})
      : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final Map<String, GlobalKey> _cardKeys = {};

  /// The card being dragged over this column.
  String? _draggingId;

  /// Where the dragged card will land among the other cards.
  int? _insertIndex;
  double _gapHeight = 0;

  /// Turned off for a frame when a drag starts or drops, so the gap
  /// appears / disappears in step with the card instead of animating.
  bool _animate = true;

  List<Todo> _todosExcept(String? id) =>
      widget.list.where((todo) => todo.id != id).toList();

  GlobalKey _keyFor(String id) => _cardKeys.putIfAbsent(id, () => GlobalKey());

  void _updateGap({String? draggingId, int? insertIndex, bool animate = true}) {
    if (draggingId == _draggingId && insertIndex == _insertIndex) {
      return;
    }
    setState(() {
      _draggingId = draggingId;
      _insertIndex = insertIndex;
      _animate = animate;
    });
    if (!animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _animate = true);
        }
      });
    }
  }

  /// Finds where the dragged card should be inserted by comparing the
  /// pointer with the middle of each card in the column.
  int _insertIndexFor(TodoDragData data, Offset feedbackOffset) {
    var pointerY = feedbackOffset.dy + data.grabOffset.dy;
    var others = _todosExcept(data.todo.id);
    for (var i = 0; i < others.length; i++) {
      var box = _cardKeys[others[i].id]?.currentContext?.findRenderObject()
          as RenderBox?;
      if (box == null || !box.attached) {
        continue;
      }
      var cardMiddle = box.localToGlobal(box.size.center(Offset.zero)).dy;
      if (pointerY < cardMiddle) {
        return i;
      }
    }
    return others.length;
  }

  void _onMove(DragTargetDetails<TodoDragData> details) {
    var data = details.data;
    _gapHeight = data.height;
    _updateGap(
        draggingId: data.todo.id,
        insertIndex: _insertIndexFor(data, details.offset));
  }

  void _onAccept(DragTargetDetails<TodoDragData> details) {
    var data = details.data;
    var others = _todosExcept(data.todo.id);
    var index = _insertIndex ?? others.length;
    var beforeTodoId = index < others.length ? others[index].id : null;
    _updateGap(animate: false);
    handleMoveTodo(widget.state,
        todoId: data.todo.id,
        fromColumnId: data.fromColumnId,
        toColumnId: widget.columnId,
        beforeTodoId: beforeTodoId);
  }

  void _onDragStarted(TodoDragData data, int index) {
    var box = _cardKeys[data.todo.id]?.currentContext?.findRenderObject()
        as RenderBox?;
    data.height = box?.size.height ?? 0;
    _gapHeight = data.height;
    // Open the gap where the card was so nothing jumps when it's picked up
    _updateGap(draggingId: data.todo.id, insertIndex: index, animate: false);
  }

  Widget _gap(Key key, bool isOpen) {
    return AnimatedContainer(
      key: key,
      duration: _animate ? _animationDuration : Duration.zero,
      curve: _animationCurve,
      height: isOpen ? _gapHeight : 0,
      margin: EdgeInsets.only(bottom: isOpen ? _cardSpacing : 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(25, 255, 255, 255),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _card(Todo todo, int index) {
    var data = TodoDragData(todo: todo, fromColumnId: widget.columnId);
    var card = Listener(
      key: _keyFor(todo.id),
      onPointerDown: (event) => data.grabOffset = event.localPosition,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _cardSpacing),
        child: TodoCard(
            todoItem: todo, addNewTodoController: widget.addNewTodoController),
      ),
    );
    var feedback = Transform.rotate(
      angle: 0.03,
      child: Material(
        color: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(4),
        child: TodoCard(
            todoItem: todo, addNewTodoController: widget.addNewTodoController),
      ),
    );
    void onDragEnd(_) {
      if (mounted && _draggingId == todo.id) {
        _updateGap();
      }
    }

    // On touch screens a plain drag should scroll, so wait for a long press
    var isTouch = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (isTouch) {
      return LongPressDraggable<TodoDragData>(
        key: ValueKey(todo.id),
        data: data,
        feedback: feedback,
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () => _onDragStarted(data, index),
        onDragEnd: onDragEnd,
        child: card,
      );
    }
    return Draggable<TodoDragData>(
      key: ValueKey(todo.id),
      data: data,
      feedback: feedback,
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () => _onDragStarted(data, index),
      onDragEnd: onDragEnd,
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    var ids = widget.list.map((todo) => todo.id).toSet();
    _cardKeys.removeWhere((id, _) => !ids.contains(id));

    var children = <Widget>[];
    var otherIndex = 0;
    for (var i = 0; i < widget.list.length; i++) {
      var todo = widget.list[i];
      if (todo.id != _draggingId) {
        children
            .add(_gap(ValueKey('gap-${todo.id}'), _insertIndex == otherIndex));
        otherIndex++;
      }
      children.add(_card(todo, i));
    }
    children.add(_gap(const ValueKey('gap-end'), _insertIndex == otherIndex));

    return DragTarget<TodoDragData>(
      onWillAccept: (data) => data != null,
      onMove: _onMove,
      onLeave: (_) => _updateGap(),
      onAcceptWithDetails: _onAccept,
      builder: (context, candidateItems, rejectedItems) {
        return AnimatedContainer(
          duration: _animationDuration,
          width: cardWidth,
          decoration: BoxDecoration(
            color: candidateItems.isNotEmpty
                ? const Color.fromARGB(45, 255, 255, 255)
                : const Color.fromARGB(30, 255, 255, 255),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(children: children),
          ),
        );
      },
    );
  }
}
