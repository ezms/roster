import 'package:flutter/material.dart';
import 'package:mobile/core/app_router.dart';
import 'package:mobile/core/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    final hasToken = await AuthController().checkAuthTokenPresent();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      hasToken ? AppRouter.home : AppRouter.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
