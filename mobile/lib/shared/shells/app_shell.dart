import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/repositories/class_repository.dart';
import 'package:mobile/shared/widgets/footer.dart';
import 'package:mobile/shared/widgets/header.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final SchoolController _schoolController;
  late final ClassSelectionController _classSelectionController;
  late final List<Widget> _screens;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _schoolController = SchoolController();
    _classSelectionController = ClassSelectionController(ClassRepository());
    _screens = [
      HomeScreen(controller: _classSelectionController),
      const Placeholder(), // Turma
      const Placeholder(), // Relatórios
      const Placeholder(), // Configurações
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(controller: _schoolController, schoolName: () => _schoolController.schoolName),
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Footer(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
