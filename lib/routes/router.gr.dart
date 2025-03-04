// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:todo_ai/domain/model/todo_model.dart' as _i7;
import 'package:todo_ai/ui/pages/entryPoint/entry_point.dart' as _i1;
import 'package:todo_ai/ui/pages/home/home_screen.dart' as _i2;
import 'package:todo_ai/ui/pages/onboding/onboding_screen.dart' as _i3;
import 'package:todo_ai/ui/pages/todo/single_todo_page.dart' as _i4;

/// generated route for
/// [_i1.EntryPointPage]
class EntryPointRoute extends _i5.PageRouteInfo<void> {
  const EntryPointRoute({List<_i5.PageRouteInfo>? children})
    : super(EntryPointRoute.name, initialChildren: children);

  static const String name = 'EntryPointRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.EntryPointPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.OnbodingScreen]
class OnbodingRoute extends _i5.PageRouteInfo<void> {
  const OnbodingRoute({List<_i5.PageRouteInfo>? children})
    : super(OnbodingRoute.name, initialChildren: children);

  static const String name = 'OnbodingRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.OnbodingScreen();
    },
  );
}

/// generated route for
/// [_i4.SingleTodoPage]
class SingleTodoRoute extends _i5.PageRouteInfo<SingleTodoRouteArgs> {
  SingleTodoRoute({
    _i6.Key? key,
    required _i7.Todo todo,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         SingleTodoRoute.name,
         args: SingleTodoRouteArgs(key: key, todo: todo),
         initialChildren: children,
       );

  static const String name = 'SingleTodoRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SingleTodoRouteArgs>();
      return _i4.SingleTodoPage(key: args.key, todo: args.todo);
    },
  );
}

class SingleTodoRouteArgs {
  const SingleTodoRouteArgs({this.key, required this.todo});

  final _i6.Key? key;

  final _i7.Todo todo;

  @override
  String toString() {
    return 'SingleTodoRouteArgs{key: $key, todo: $todo}';
  }
}
