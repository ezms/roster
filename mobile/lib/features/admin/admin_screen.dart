import 'package:flutter/material.dart';
import 'package:mobile/core/auth_controller.dart';
import 'package:mobile/features/admin/controllers/admin_cards_controller.dart';
import 'package:mobile/features/admin/controllers/admin_screen_controller.dart';
import 'package:mobile/features/admin/screens/cards/admin_cards_screen.dart';
import 'package:mobile/features/admin/screens/classes/admin_classes_screen.dart';
import 'package:mobile/features/admin/screens/students/admin_students_screen.dart';
import 'package:mobile/features/admin/widgets/admin_item_card.dart';
import 'package:mobile/features/super_admin/super_admin_shell.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/models/label_value.dart';

class AdminScreen extends StatefulWidget {
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
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isSuperUser = false;

  @override
  void initState() {
    super.initState();
    AuthController().checkIsSuperUser().then((value) {
      if (mounted) setState(() => _isSuperUser = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final stats = widget.controller.stats;
              final isLoading = widget.controller.isLoading;

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
                        schoolController: widget.schoolController,
                        classSelectionController: widget.classSelectionController,
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
                    schoolController: widget.schoolController,
                    classSelectionController: widget.classSelectionController,
                  ),
                ),
              );
            },
          ),
          ListenableBuilder(
            listenable: widget.adminCardsController,
            builder: (context, _) {
              final isLoading = widget.adminCardsController.isLoading;
              return AdminItemCard(
                icon: const Text('🪪', style: TextStyle(fontSize: 22)),
                title: 'Gerenciar Carteirinhas',
                stats: [
                  LabelValue(
                    value: isLoading ? '...' : widget.adminCardsController.totalWithCard.toString(),
                    label: 'Carteirinhas Emitidas',
                  ),
                  LabelValue(
                    value: isLoading ? '...' : widget.adminCardsController.totalWithoutCard.toString(),
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
                        schoolController: widget.schoolController,
                        controller: widget.adminCardsController,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isSuperUser)
            AdminItemCard(
              icon: const Text('🔧', style: TextStyle(fontSize: 22)),
              title: 'Gestão de Plataforma',
              stats: const [],
              badges: const [],
              badgeLabel: '',
              buttonText: 'Gerenciar Escolas e Usuários',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SuperAdminShell()),
                );
              },
            ),
        ],
      ),
    );
  }
}
