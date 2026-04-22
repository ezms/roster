import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final ChangeNotifier controller;
  final String Function() schoolName;
  final bool showBackButton;

  const Header({super.key, required this.controller, required this.schoolName, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => AppBar(
        title: Text(
          schoolName(),
          style: const TextStyle(fontSize: 16, color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        automaticallyImplyLeading: showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
