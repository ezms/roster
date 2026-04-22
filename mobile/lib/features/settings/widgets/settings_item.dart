import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/settings/models/settings_item_model.dart';

class SettingsItem extends StatelessWidget {
  final SettingsItemModel model;

  const SettingsItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: model.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(model.icon, size: 22, color: model.iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                model.label,
                style: TextStyle(fontSize: 15, color: model.labelColor),
              ),
            ),
            if (model.trailing != null) model.trailing!,
            if (model.trailing == null && model.onTap != null)
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
