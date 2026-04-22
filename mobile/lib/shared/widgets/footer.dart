import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const Footer({super.key, required this.currentIndex, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Escola'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
      ],
    );
  }
}
