import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'locator.dart';
import 'service/service.dart';
import 'ui/ui.dart';

Future<bool> _isLocaleExists() async {
  final locale = await locate<AppPreference>().readLocalePreference();
  if (locale == null) return false;

  locate<AppLocaleNotifier>().setLocale(locale);
  return true;
}

GlobalKey<NavigatorState> mainNavigationKey = GlobalKey();

final routerRefreshListenable = Listenable.merge([
  locate<AuthSessionShockerEventHandler>(),
]);

GoRouter baseRouter = GoRouter(
  initialLocation: "/",
  navigatorKey: mainNavigationKey,
  refreshListenable: routerRefreshListenable,
  redirect: (context, state) {
    if (locate<AuthSessionShockerEventHandler>().value is Exception) return "/login";
    return null;
  },
  routes: [
    GoRoute(
      path: "/",
      redirect: (context, state) async {
        return await _isLocaleExists() ? "/login" : "/locale";
      },
    ),
    GoRoute(
      path: "/login",
      builder: (context, state) => const MobileVerifierFormStandaloneView(),
    ),
    GoRoute(
      path: "/locale",
      parentNavigatorKey: mainNavigationKey,
      builder: (context, state) => LocaleSelectorView(
        onDone: () => GoRouter.of(context).go("/"),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => AppPage(child: child),
      routes: [
        GoRoute(
          path: "/orders",
          builder: (context, state) => const OrderView(),
        ),
        GoRoute(
          path: "/reports",
          builder: (context, state) => const ReportView(),
        ),
        GoRoute(
          path: "/profile",
          builder: (context, state) => const ProfileView(),
        ),
        GoRoute(
          path: "/notification",
          builder: (context, state) => const NotificationsView(),
        ),
      ],
    ),
  ],
);
