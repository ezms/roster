import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';

class SettingsItemModel {
  final IconData icon;
  final String label;
  final Color labelColor;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsItemModel({
    required this.icon,
    required this.label,
    this.labelColor = AppColors.textPrimary,
    this.iconColor = AppColors.textSecondary,
    this.onTap,
    this.trailing,
  });
}
