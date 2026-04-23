import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';

class ClassSelector extends StatefulWidget {
  final ClassSelectionController controller;

  const ClassSelector({super.key, required this.controller});

  @override
  State<ClassSelector> createState() => _ClassSelectorState();
}

class _ClassSelectorState extends State<ClassSelector> {
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
    if (!widget.controller.loaded) {
      return const CircularProgressIndicator();
    }

    if (widget.controller.classes.isEmpty) {
      return const Text('Nenhuma turma cadastrada');
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Turma',
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      ),
      child: DropdownButton<Class>(
        hint: const Text('Selecione uma turma'),
        value: widget.controller.selected,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: widget.controller.classes
            .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
            .toList(),
        onChanged: widget.controller.select,
      ),
    );
  }
}
