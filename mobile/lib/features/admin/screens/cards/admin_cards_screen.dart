import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/core/models/student.dart';
import 'package:mobile/features/admin/controllers/admin_cards_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/widgets/header.dart';

class AdminCardsScreen extends StatelessWidget {
  final SchoolController schoolController;
  final AdminCardsController controller;

  const AdminCardsScreen({
    super.key,
    required this.schoolController,
    required this.controller,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Header(
        controller: schoolController,
        schoolName: () => schoolController.schoolName,
        showBackButton: true,
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          if (controller.students.isEmpty) {
            return const Center(child: Text('Nenhum aluno cadastrado.'));
          }

          final sorted = [...controller.students]
            ..sort((a, b) {
              if (a.card == null && b.card != null) return -1;
              if (a.card != null && b.card == null) return 1;
              return a.name.compareTo(b.name);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final student = sorted[index];
              return _StudentCardTile(student: student, formatDate: _formatDate);
            },
          );
        },
      ),
    );
  }
}

class _StudentCardTile extends StatelessWidget {
  final Student student;
  final String Function(DateTime) formatDate;

  const _StudentCardTile({required this.student, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final hasCard = student.card != null;

    return Card(
      child: ListTile(
        title: Text(student.name),
        subtitle: Text(student.code),
        trailing: hasCard
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'v${student.card!.version}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    formatDate(student.card!.issuedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Sem carteirinha',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
      ),
    );
  }
}
