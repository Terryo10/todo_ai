import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/routes/router.gr.dart';

import '../../domain/bloc/auth_bloc/auth_bloc.dart';

class LoginGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    final context = router.navigatorKey.currentContext;
    
    if (context == null) {
      resolver.next(false);
      return;
    }

    try {
      final authState = context.read<AuthBloc>().state;
      
      if (authState is AuthAuthenticatedState) {
        await router.push(const EntryPointRoute());
        resolver.next(false);
      } else {

        resolver.next(true);
      }
    } catch (e) {
      debugPrint('LoginGuard error: $e');
      resolver.next(true); 
    }
  }
}