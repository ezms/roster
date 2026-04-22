import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/admin/widgets/badge_chip.dart';
import 'package:mobile/features/admin/widgets/stat_item.dart';
import 'package:mobile/shared/models/label_value.dart';

class AdminItemCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final List<LabelValue> stats;
  final List<int> badges;
  final String badgeLabel;
  final String buttonText;
  final VoidCallback onPressed;

  const AdminItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.stats,
    required this.badges,
    required this.badgeLabel,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  State<AdminItemCard> createState() => _AdminItemCardState();
}

class _AdminItemCardState extends State<AdminItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildStats(),
            const SizedBox(height: 12),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        widget.icon,
        const SizedBox(width: 8),
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: widget.stats
          .map((stat) => Expanded(child: StatItem(stat: stat)))
          .toList(),
    );
  }

  Widget _buildBottom() {
    return Row(
      children: [
        ...widget.badges.map(
          (count) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: BadgeChip(count: count),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          widget.badgeLabel,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(widget.buttonText),
        ),
      ],
    );
  }
}
