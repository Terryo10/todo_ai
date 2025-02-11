// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:todo_ai/ui/pages/landing_page.dart' as _i3;
import 'package:todo_ai/ui/screens/entryPoint/entry_point.dart' as _i1;
import 'package:todo_ai/ui/screens/home/home_screen.dart' as _i2;
import 'package:todo_ai/ui/screens/onboding/onboding_screen.dart' as _i4;

/// generated route for
/// [_i1.EntryPoint]
class EntryPoint extends _i5.PageRouteInfo<void> {
  const EntryPoint({List<_i5.PageRouteInfo>? children})
    : super(EntryPoint.name, initialChildren: children);

  static const String name = 'EntryPoint';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.EntryPoint();
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
/// [_i3.LandingPage]
class LandingRoute extends _i5.PageRouteInfo<void> {
  const LandingRoute({List<_i5.PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.LandingPage();
    },
  );
}

/// generated route for
/// [_i4.OnbodingScreen]
class OnbodingRoute extends _i5.PageRouteInfo<void> {
  const OnbodingRoute({List<_i5.PageRouteInfo>? children})
    : super(OnbodingRoute.name, initialChildren: children);

  static const String name = 'OnbodingRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.OnbodingScreen();
    },
  );
}
