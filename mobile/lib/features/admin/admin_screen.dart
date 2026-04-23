import 'package:flutter/material.dart';
import 'package:mobile/features/admin/controllers/admin_screen_controller.dart';
import 'package:mobile/features/admin/screens/classes/admin_classes_screen.dart';
import 'package:mobile/features/admin/widgets/admin_item_card.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/models/label_value.dart';

class AdminScreen extends StatelessWidget {
  final AdminScreenController controller;
  final SchoolController schoolController;
  final ClassSelectionController classSelectionController;

  const AdminScreen({
    super.key,
    required this.controller,
    required this.schoolController,
    required this.classSelectionController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final stats = controller.stats;
              final isLoading = controller.isLoading;

              return AdminItemCard(
                icon: const Text('🏫', style: TextStyle(fontSize: 22)),
                title: 'Gestão de Turmas',
                stats: [
                  LabelValue(
                    value: isLoading ? '...' : (stats?.total.toString() ?? '0'),
                    label: 'Turmas Ativas',
                  ),
                ],
                badges: const [],
                badgeLabel: '',
                buttonText: 'Visualizar detalhes',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminClassesScreen(
                        schoolController: schoolController,
                        classSelectionController: classSelectionController,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          AdminItemCard(
            icon: const Text('👥', style: TextStyle(fontSize: 22)),
            title: 'Gestão de Alunos',
            stats: const [
              LabelValue(value: '350', label: 'Alunos Matriculados'),
              LabelValue(value: '10', label: 'Contratados'),
            ],
            badges: const [10],
            badgeLabel: '10 Matrículas Pendentes',
            buttonText: 'Matricular Aluno',
            onPressed: () {},
          ),
          AdminItemCard(
            icon: const Text('🪪', style: TextStyle(fontSize: 22)),
            title: 'Gerenciar Carteirinhas',
            stats: const [
              LabelValue(value: '320', label: 'Carteirinhas v2 Emitidas'),
              LabelValue(value: '30', label: 'Renovações Próximas'),
            ],
            badges: const [320, 30],
            badgeLabel: '30 Próximas',
            buttonText: 'Emitir Novas',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
