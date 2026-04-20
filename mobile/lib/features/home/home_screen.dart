import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/features/home/controllers/class_controller.dart';
import 'package:mobile/features/home/controllers/home_controller.dart';
import 'package:mobile/shared/widgets/header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _homeController;
  late final ClassController _classController;
  Class? _selectedClass;
  bool _pressed = false;

  String get _buttonLabel {
    if (!_classController.loaded) return '...';
    if (_classController.classes.isEmpty) return 'Sem turmas';
    if (_selectedClass == null) return 'Selecione uma turma';
    return 'Iniciar';
  }

  bool get _buttonEnabled =>
      _classController.loaded &&
      _classController.classes.isNotEmpty &&
      _selectedClass != null;

  @override
  void initState() {
    super.initState();
    _homeController = HomeController();
    _classController = ClassController();
    _classController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        controller: _homeController,
        schoolName: () => _homeController.schoolName,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _classController.classes.isEmpty
                ? const Text('Nenhuma turma cadastrada')
                : DropdownButton<Class>(
                    hint: const Text('Selecione uma turma'),
                    value: _selectedClass,
                    items: _classController.classes
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedClass = value),
                  ),
            const SizedBox(height: 32),
            AnimatedScale(
              scale: _pressed ? 0.42 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                child: OutlinedButton(
                  onPressed: _buttonEnabled ? () {} : null,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border, width: 5.5),
                    padding: const EdgeInsets.all(40),
                  ),
                  child: Text(
                    _buttonLabel,
                    style: TextStyle(
                      color: _buttonEnabled
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
