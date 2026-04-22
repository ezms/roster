import 'package:flutter/material.dart';
import 'package:mobile/features/class/widgets/student_list.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/widgets/class_selector.dart';

class ClassScreen extends StatelessWidget {
  final ClassSelectionController controller;

  const ClassScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecione uma Turma:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: ClassSelector(controller: controller),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StudentList(classSelectionController: controller),
        ),
      ],
    );
  }
}
