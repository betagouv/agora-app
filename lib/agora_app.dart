import 'package:agora/agora_app_router.dart';
import 'package:agora/common/analytics/matomo_route_observer.dart';
import 'package:agora/design/style/agora_colors.dart';
import 'package:agora/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgoraApp extends StatelessWidget {
  final SharedPreferences sharedPref;
  static final matomoRouteObserver = MatomoRouteObserver();

  const AgoraApp({super.key, required this.sharedPref});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Agora",
      initialRoute: LoadingPage.routeName,
      navigatorObservers: [
        matomoRouteObserver,
      ],
      routes: AgoraAppRouter.handleAgoraRoutes(),
      onGenerateRoute: (RouteSettings settings) => AgoraAppRouter.handleAgoraGenerateRoute(settings, sharedPref),
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AgoraColors.primaryGreen,
          secondary: AgoraColors.primaryGreen,
        ),
      ),
    );
  }
}
