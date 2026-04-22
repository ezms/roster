import 'package:flutter/material.dart';
import 'package:mobile/features/login/login_screen.dart';
import 'package:mobile/features/splash/splash_screen.dart';
import 'package:mobile/shared/shells/app_shell.dart';

class AppRouter {
  static const String splash = "/";
  static const String home = "/home";
  static const String login = "/login";

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const AppShell(),
    login: (context) => const LoginScreen(),
  };
}
