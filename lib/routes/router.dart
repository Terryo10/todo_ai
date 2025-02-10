import 'package:auto_route/auto_route.dart';
import '/routes/router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: OnbodingRoute.page, initial: true),
        AutoRoute(page: LandingRoute.page),
        AutoRoute(page: HomeRoute.page),
      ];
}
