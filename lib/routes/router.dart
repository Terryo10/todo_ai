import 'package:auto_route/auto_route.dart';
import 'package:todo_ai/routes/guards/auth_guard.dart';
import '/routes/router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            page: OnbodingRoute.page, initial: true,),
        AutoRoute(page: HomeRoute.page, guards: [AuthGuard()]),
        AutoRoute(page: EntryPointRoute.page, guards: [AuthGuard()]),
      ];
}
