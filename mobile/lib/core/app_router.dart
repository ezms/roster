import 'package:flutter/material.dart';
import 'package:mobile/features/home/home_screen.dart';

class AppRouter {
  static const String home = "/";

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
  };
}
