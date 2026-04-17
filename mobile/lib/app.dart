import 'package:flutter/material.dart';
import 'package:mobile/core/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roster App',
      initialRoute: AppRouter.home,
      routes: AppRouter.routes,
    );
  }
}
