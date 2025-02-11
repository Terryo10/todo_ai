import 'package:auto_route/auto_route.dart';
import '/routes/router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LandingRoute.page, initial: true),
        AutoRoute(page: OnbodingRoute.page,guards: []),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: EntryPoint.page),
      ];
}
