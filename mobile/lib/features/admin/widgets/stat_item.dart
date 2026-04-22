import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/shared/models/label_value.dart';

class StatItem extends StatelessWidget {
  final LabelValue stat;

  const StatItem({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          stat.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
