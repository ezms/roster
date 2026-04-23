import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/scanner/scanner_screen.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/widgets/class_selector.dart';

class HomeScreen extends StatefulWidget {
  final ClassSelectionController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _pressed = false;

  String get _buttonLabel {
    if (!widget.controller.loaded) return '...';
    if (widget.controller.classes.isEmpty) return 'Sem turmas';
    if (widget.controller.selected == null) return 'Selecione uma turma';
    return 'Iniciar';
  }

  bool get _buttonEnabled =>
      widget.controller.loaded &&
      widget.controller.classes.isNotEmpty &&
      widget.controller.selected != null;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ClassSelector(controller: widget.controller),
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
                onPressed: _buttonEnabled
                    ? () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) => const ScannerScreen(),
                            transitionsBuilder: (_, animation, _, child) {
                              final curved = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              );
                              return FadeTransition(
                                opacity: curved,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        )
                    : null,
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
    );
  }
}
