// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:todo_ai/ui/pages/entryPoint/entry_point.dart' as _i1;
import 'package:todo_ai/ui/pages/home/home_screen.dart' as _i2;
import 'package:todo_ai/ui/pages/onboding/onboding_screen.dart' as _i3;

/// generated route for
/// [_i1.EntryPointPage]
class EntryPointRoute extends _i4.PageRouteInfo<void> {
  const EntryPointRoute({List<_i4.PageRouteInfo>? children})
    : super(EntryPointRoute.name, initialChildren: children);

  static const String name = 'EntryPointRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.EntryPointPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.OnbodingScreen]
class OnbodingRoute extends _i4.PageRouteInfo<void> {
  const OnbodingRoute({List<_i4.PageRouteInfo>? children})
    : super(OnbodingRoute.name, initialChildren: children);

  static const String name = 'OnbodingRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.OnbodingScreen();
    },
  );
}
