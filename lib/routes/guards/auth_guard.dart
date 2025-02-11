import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/routes/router.gr.dart';

import '../../domain/bloc/auth_bloc/auth_bloc.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final context = router.navigatorKey.currentContext;
    if (context == null) {
      resolver.next(false);
      return;
    }
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticatedState) {
      resolver.next(true);
    } else {
      router.push(const OnbodingRoute());
      resolver.next(false);
    }
  }
}
