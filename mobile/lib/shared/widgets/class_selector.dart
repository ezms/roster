import 'package:flutter/material.dart';
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

    return DropdownButton<Class>(
      hint: const Text('Selecione uma turma'),
      value: widget.controller.selected,
      items: widget.controller.classes
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: widget.controller.select,
    );
  }
}
