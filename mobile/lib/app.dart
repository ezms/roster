import 'package:flutter/material.dart';
import 'package:mobile/core/app_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Roster App',
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}
