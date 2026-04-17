import 'package:flutter/material.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/splash/splash_screen.dart';

class AppRouter {
  static const String splash = "/";
  static const String home = "/home";
  static const String login = "/login";

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
  };
}
