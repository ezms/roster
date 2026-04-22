import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';

class BadgeChip extends StatelessWidget {
  final int count;

  const BadgeChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFE8EDF5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
