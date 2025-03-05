// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:todo_ai/domain/model/todo_model.dart' as _i9;
import 'package:todo_ai/ui/pages/entryPoint/entry_point.dart' as _i1;
import 'package:todo_ai/ui/pages/home/home_screen.dart' as _i2;
import 'package:todo_ai/ui/pages/onboding/onboding_screen.dart' as _i3;
import 'package:todo_ai/ui/pages/profile/profile_page.dart' as _i4;
import 'package:todo_ai/ui/pages/todo/single_task_detail_page.dart' as _i5;
import 'package:todo_ai/ui/pages/todo/single_todo_page.dart' as _i6;

/// generated route for
/// [_i1.EntryPointPage]
class EntryPointRoute extends _i7.PageRouteInfo<void> {
  const EntryPointRoute({List<_i7.PageRouteInfo>? children})
    : super(EntryPointRoute.name, initialChildren: children);

  static const String name = 'EntryPointRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.EntryPointPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.OnbodingScreen]
class OnbodingRoute extends _i7.PageRouteInfo<void> {
  const OnbodingRoute({List<_i7.PageRouteInfo>? children})
    : super(OnbodingRoute.name, initialChildren: children);

  static const String name = 'OnbodingRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.OnbodingScreen();
    },
  );
}

/// generated route for
/// [_i4.ProfilePage]
class ProfileRoute extends _i7.PageRouteInfo<void> {
  const ProfileRoute({List<_i7.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.ProfilePage();
    },
  );
}

/// generated route for
/// [_i5.SingleTaskDetailPage]
class SingleTaskDetailRoute
    extends _i7.PageRouteInfo<SingleTaskDetailRouteArgs> {
  SingleTaskDetailRoute({
    _i8.Key? key,
    required String todoId,
    required String taskId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         SingleTaskDetailRoute.name,
         args: SingleTaskDetailRouteArgs(
           key: key,
           todoId: todoId,
           taskId: taskId,
         ),
         initialChildren: children,
       );

  static const String name = 'SingleTaskDetailRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SingleTaskDetailRouteArgs>();
      return _i5.SingleTaskDetailPage(
        key: args.key,
        todoId: args.todoId,
        taskId: args.taskId,
      );
    },
  );
}

class SingleTaskDetailRouteArgs {
  const SingleTaskDetailRouteArgs({
    this.key,
    required this.todoId,
    required this.taskId,
  });

  final _i8.Key? key;

  final String todoId;

  final String taskId;

  @override
  String toString() {
    return 'SingleTaskDetailRouteArgs{key: $key, todoId: $todoId, taskId: $taskId}';
  }
}

/// generated route for
/// [_i6.SingleTodoPage]
class SingleTodoRoute extends _i7.PageRouteInfo<SingleTodoRouteArgs> {
  SingleTodoRoute({
    _i8.Key? key,
    required _i9.Todo todo,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         SingleTodoRoute.name,
         args: SingleTodoRouteArgs(key: key, todo: todo),
         initialChildren: children,
       );

  static const String name = 'SingleTodoRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SingleTodoRouteArgs>();
      return _i6.SingleTodoPage(key: args.key, todo: args.todo);
    },
  );
}

class SingleTodoRouteArgs {
  const SingleTodoRouteArgs({this.key, required this.todo});

  final _i8.Key? key;

  final _i9.Todo todo;

  @override
  String toString() {
    return 'SingleTodoRouteArgs{key: $key, todo: $todo}';
  }
}
