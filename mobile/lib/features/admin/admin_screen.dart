import 'package:flutter/material.dart';
import 'package:mobile/features/admin/controllers/admin_cards_controller.dart';
import 'package:mobile/features/admin/controllers/admin_screen_controller.dart';
import 'package:mobile/features/admin/screens/cards/admin_cards_screen.dart';
import 'package:mobile/features/admin/screens/classes/admin_classes_screen.dart';
import 'package:mobile/features/admin/screens/students/admin_students_screen.dart';
import 'package:mobile/features/admin/widgets/admin_item_card.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/models/label_value.dart';

class AdminScreen extends StatelessWidget {
  final AdminScreenController controller;
  final SchoolController schoolController;
  final ClassSelectionController classSelectionController;
  final AdminCardsController adminCardsController;

  const AdminScreen({
    super.key,
    required this.controller,
    required this.schoolController,
    required this.classSelectionController,
    required this.adminCardsController,
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
            stats: const [],
            badges: const [],
            badgeLabel: '',
            buttonText: 'Gerenciar Alunos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminStudentsScreen(
                    schoolController: schoolController,
                    classSelectionController: classSelectionController,
                  ),
                ),
              );
            },
          ),
          ListenableBuilder(
            listenable: adminCardsController,
            builder: (context, _) {
              final isLoading = adminCardsController.isLoading;
              return AdminItemCard(
                icon: const Text('🪪', style: TextStyle(fontSize: 22)),
                title: 'Gerenciar Carteirinhas',
                stats: [
                  LabelValue(
                    value: isLoading ? '...' : adminCardsController.totalWithCard.toString(),
                    label: 'Carteirinhas Emitidas',
                  ),
                  LabelValue(
                    value: isLoading ? '...' : adminCardsController.totalWithoutCard.toString(),
                    label: 'Alunos sem Carteirinha',
                  ),
                ],
                badges: const [],
                badgeLabel: '',
                buttonText: 'Visualizar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminCardsScreen(
                        schoolController: schoolController,
                        controller: adminCardsController,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
