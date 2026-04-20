import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final ChangeNotifier controller;
  final String Function() schoolName;

  const Header({super.key, required this.controller, required this.schoolName});

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
        automaticallyImplyLeading: false,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
