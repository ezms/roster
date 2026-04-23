import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/admin/controllers/admin_cards_controller.dart';
import 'package:mobile/features/admin/controllers/admin_screen_controller.dart';
import 'package:mobile/features/class/class_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/reports/reports_controller.dart';
import 'package:mobile/features/reports/reports_screen.dart';
import 'package:mobile/features/settings/settings_screen.dart';
import 'package:mobile/features/admin/admin_screen.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/controllers/user_controller.dart';
import 'package:mobile/shared/repositories/class_repository.dart';
import 'package:mobile/shared/repositories/reports_repository.dart';
import 'package:mobile/shared/repositories/student_repository.dart';
import 'package:mobile/shared/repositories/user_repository.dart';
import 'package:mobile/shared/widgets/footer.dart';
import 'package:mobile/shared/widgets/header.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final SchoolController _schoolController;
  late final UserController _userController;
  late final ClassSelectionController _classSelectionController;
  late final AdminScreenController _adminScreenController;
  late final AdminCardsController _adminCardsController;
  late final ReportsController _reportsController;
  late final List<Widget> _screens;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _schoolController = SchoolController();
    _userController = UserController(UserRepository());
    _classSelectionController = ClassSelectionController(ClassRepository());
    _adminScreenController = AdminScreenController(ClassRepository());
    _adminCardsController = AdminCardsController(StudentRepository());
    _reportsController = ReportsController(ReportsRepository());

    _screens = [
      HomeScreen(controller: _classSelectionController),
      ClassScreen(controller: _classSelectionController),
      AdminScreen(
        controller: _adminScreenController,
        schoolController: _schoolController,
        classSelectionController: _classSelectionController,
        adminCardsController: _adminCardsController,
      ),
      ReportsScreen(
        controller: _reportsController,
        classSelectionController: _classSelectionController,
        schoolController: _schoolController,
      ),
      SettingsScreen(
        schoolController: _schoolController,
        userController: _userController,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        controller: _schoolController,
        schoolName: () => _schoolController.schoolName,
      ),
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Footer(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
