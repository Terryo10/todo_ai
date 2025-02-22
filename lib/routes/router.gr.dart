// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;
import 'package:todo_ai/domain/model/todo_model.dart' as _i8;
import 'package:todo_ai/ui/pages/entryPoint/entry_point.dart' as _i1;
import 'package:todo_ai/ui/pages/home/home_screen.dart' as _i2;
import 'package:todo_ai/ui/pages/onboding/onboding_screen.dart' as _i3;
import 'package:todo_ai/ui/pages/todo/todo_list_page.dart' as _i4;
import 'package:todo_ai/ui/pages/todo/todo_screen.dart' as _i5;

/// generated route for
/// [_i1.EntryPointPage]
class EntryPointRoute extends _i6.PageRouteInfo<void> {
  const EntryPointRoute({List<_i6.PageRouteInfo>? children})
    : super(EntryPointRoute.name, initialChildren: children);

  static const String name = 'EntryPointRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.EntryPointPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.OnbodingScreen]
class OnbodingRoute extends _i6.PageRouteInfo<void> {
  const OnbodingRoute({List<_i6.PageRouteInfo>? children})
    : super(OnbodingRoute.name, initialChildren: children);

  static const String name = 'OnbodingRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.OnbodingScreen();
    },
  );
}

/// generated route for
/// [_i4.TodoListPage]
class TodoListRoute extends _i6.PageRouteInfo<TodoListRouteArgs> {
  TodoListRoute({
    _i7.Key? key,
    required _i8.Todo todo,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         TodoListRoute.name,
         args: TodoListRouteArgs(key: key, todo: todo),
         initialChildren: children,
       );

  static const String name = 'TodoListRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TodoListRouteArgs>();
      return _i4.TodoListPage(key: args.key, todo: args.todo);
    },
  );
}

class TodoListRouteArgs {
  const TodoListRouteArgs({this.key, required this.todo});

  final _i7.Key? key;

  final _i8.Todo todo;

  @override
  String toString() {
    return 'TodoListRouteArgs{key: $key, todo: $todo}';
  }
}

/// generated route for
/// [_i5.TodoScreenPage]
class TodoRouteRoute extends _i6.PageRouteInfo<void> {
  const TodoRouteRoute({List<_i6.PageRouteInfo>? children})
    : super(TodoRouteRoute.name, initialChildren: children);

  static const String name = 'TodoRouteRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.TodoScreenPage();
    },
  );
}
