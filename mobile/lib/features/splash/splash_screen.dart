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
    final auth = AuthController();
    final hasToken = await auth.checkAuthTokenPresent();
    if (!mounted) return;
    if (!hasToken) {
      Navigator.pushReplacementNamed(context, AppRouter.login);
      return;
    }
    final isSuper = await auth.checkIsSuperUser();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, isSuper ? AppRouter.super_ : AppRouter.home);
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
