import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/settings/models/settings_item_model.dart';
import 'package:mobile/features/settings/widgets/settings_item.dart';
import 'package:mobile/features/settings/widgets/user_info_card.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  final SchoolController schoolController;

  const SettingsScreen({super.key, required this.schoolController});

  @override
  Widget build(BuildContext context) {
    final mainItems = [
      const SettingsItemModel(
        icon: Icons.lock_outline,
        label: 'Trocar senha',
        onTap: null,
      ),
      SettingsItemModel(
        icon: Icons.dark_mode_outlined,
        label: 'Dark mode',
        trailing: Switch(value: false, onChanged: (_) {}),
      ),
    ];

    final bottomItems = [
      const SettingsItemModel(
        icon: Icons.help_outline,
        label: 'Ajuda',
        onTap: null,
      ),
      SettingsItemModel(
        icon: Icons.logout,
        label: 'Sair',
        labelColor: AppColors.error,
        iconColor: AppColors.error,
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserInfoCard(schoolController: schoolController),
        const SizedBox(height: 8),
        ...mainItems.map((item) => SettingsItem(model: item)),
        const Spacer(),
        const Divider(height: 1),
        ...bottomItems.map((item) => SettingsItem(model: item)),
        const SizedBox(height: 16),
      ],
    );
  }
}
