import 'dart:ui';

import 'package:get_it/get_it.dart';

import 'service/service.dart';
import 'ui/ui.dart';

GetIt getIt = GetIt.instance;

class LocatorConfig {
  LocatorConfig({
    required this.authority,
    this.pathPrefix,
  });

  final String authority;

  final String? pathPrefix;
}

setupServiceLocator(LocatorConfig config) async {
  getIt.registerSingleton(config);

  getIt.registerSingleton(AppLocaleNotifier(const Locale("en")));
  getIt.registerSingleton(AppPreference());

  final authSessionEventHandler = AuthSessionShockerEventHandler();
  final authService = RestAuthService(
    config: RestAuthServiceConfig(
      authority: config.authority,
      pathPrefix: config.pathPrefix,
    ),
  )..setEventHandler(authSessionEventHandler);

  final restService = RestService(
    authService: authService,
    config: RestServiceConfig(
      authority: config.authority,
      pathPrefix: config.pathPrefix,
    ),
  );

  getIt.registerSingleton(authService);
  getIt.registerSingleton(authSessionEventHandler);
  getIt.registerSingleton(restService);

  getIt.registerSingleton(OrdersRepo());
  getIt.registerSingleton(ReportsRepo());

  /// In-App Notifications
  getIt.registerSingleton(InAppNotificationHandler(restService: restService));
  getIt.registerSingleton(CloudMessagingHelperService(restService: restService));

  getIt.registerSingleton(VendorService(null));

  getIt.registerLazySingleton(() => ProgressIndicatorController());
  getIt.registerSingleton(PopupController());
}

T locate<T extends Object>() => GetIt.instance<T>();
