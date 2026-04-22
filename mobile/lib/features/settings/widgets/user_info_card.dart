import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/controllers/user_controller.dart';

class UserInfoCard extends StatelessWidget {
  final SchoolController schoolController;
  final UserController userController;

  const UserInfoCard({
    super.key,
    required this.schoolController,
    required this.userController,
  });

  String get _roleLabel {
    return switch (userController.user?.role) {
      'admin' => 'Administrador',
      'teacher' => 'Professor',
      _ => '—',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([schoolController, userController]),
      builder: (context, _) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userController.user?.name ?? '—',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _roleLabel,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  schoolController.schoolName,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
