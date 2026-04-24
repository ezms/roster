import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/core/models/attendance_report.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/core/models/user.dart';
import 'package:mobile/features/reports/reports_controller.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/utils/report_pdf.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ReportsScreen extends StatelessWidget {
  final ReportsController controller;
  final ClassSelectionController classSelectionController;
  final SchoolController schoolController;

  const ReportsScreen({
    super.key,
    required this.controller,
    required this.classSelectionController,
    required this.schoolController,
  });

  static const _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, classSelectionController]),
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterSection(
                controller: controller,
                classSelectionController: classSelectionController,
                inputDecoration: _inputDecoration,
              ),
              if (controller.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text(controller.errorMessage!)),
                )
              else if (controller.report != null) ...[
                const SizedBox(height: 20),
                _SummarySection(summary: controller.report!.summary),
                const SizedBox(height: 20),
                _SessionsSection(
                  sessions: controller.report!.sessions,
                  showAll: controller.showAllSessions,
                  onToggle: controller.toggleShowAllSessions,
                ),
                if (controller.report!.topAbsentStudents.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _AbsentStudentsSection(students: controller.report!.topAbsentStudents),
                ],
                const SizedBox(height: 24),
                _ExportButtons(
                  onPdf: () => ReportPdf.print(
                    controller.report!,
                    schoolController.schoolName,
                    controller.selectedMonth,
                    controller.selectedYear,
                  ),
                  onCsv: () async {
                    final csv = controller.buildCsv();
                    final file = File('${Directory.systemTemp.path}/relatorio.csv');
                    await file.writeAsString(csv);
                    await Share.shareXFiles(
                      [XFile(file.path, mimeType: 'text/csv')],
                      subject: 'Relatório de Frequência',
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final ReportsController controller;
  final ClassSelectionController classSelectionController;
  final InputDecoration Function(String) inputDecoration;

  const _FilterSection({
    required this.controller,
    required this.classSelectionController,
    required this.inputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: inputDecoration('Mês'),
                child: DropdownButton<int>(
                  value: controller.selectedMonth,
                  isExpanded: true,
                  underline: const SizedBox(),
                  isDense: true,
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        ReportsScreen._months[i],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  onChanged: (v) => controller.setMonth(v!),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InputDecorator(
                decoration: inputDecoration('Ano'),
                child: DropdownButton<int>(
                  value: controller.selectedYear,
                  isExpanded: true,
                  underline: const SizedBox(),
                  isDense: true,
                  items: years
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y', style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => controller.setYear(v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: inputDecoration('Turma'),
          child: DropdownButton<Class?>(
            value: controller.selectedClass,
            isExpanded: true,
            underline: const SizedBox(),
            isDense: true,
            items: [
              const DropdownMenuItem<Class?>(
                value: null,
                child: Text('Todas as turmas', style: TextStyle(fontSize: 14)),
              ),
              ...classSelectionController.classes.map(
                (c) => DropdownMenuItem<Class?>(
                  value: c,
                  child: Text(c.name, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onChanged: controller.setClass,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: inputDecoration('Professor (opcional)'),
          child: DropdownButton<User?>(
            value: controller.selectedTeacher,
            isExpanded: true,
            underline: const SizedBox(),
            isDense: true,
            items: [
              const DropdownMenuItem<User?>(
                value: null,
                child: Text('Todos', style: TextStyle(fontSize: 14)),
              ),
              ...controller.teachers.map(
                (u) => DropdownMenuItem<User?>(
                  value: u,
                  child: Text(u.name, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onChanged: controller.setTeacher,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => controller.generateReport(classSelectionController.classes),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          icon: const Icon(Icons.bar_chart, size: 18),
          label: const Text('Gerar relatório'),
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  final ReportSummary summary;
  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo do mês',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatCard(icon: Icons.calendar_today, label: 'Aulas', value: '${summary.totalSessions}'),
            const SizedBox(width: 8),
            _StatCard(icon: Icons.check_circle_outline, label: 'Presenças', value: '${summary.totalPresences}', color: Colors.green),
            const SizedBox(width: 8),
            _StatCard(icon: Icons.cancel_outlined, label: 'Faltas', value: '${summary.totalAbsences}', color: Colors.red),
            const SizedBox(width: 8),
            _StatCard(icon: Icons.percent, label: 'Presença', value: '${summary.attendanceRate.toStringAsFixed(0)}%', color: AppColors.primary),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SessionsSection extends StatelessWidget {
  final List<ReportSession> sessions;
  final bool showAll;
  final VoidCallback onToggle;

  const _SessionsSection({
    required this.sessions,
    required this.showAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final visible = showAll ? sessions : sessions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registros de chamadas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          const Text(
            'Nenhuma sessão encontrada para este período.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else ...[
          ...visible.map((s) => _SessionTile(session: s)),
          if (sessions.length > 3)
            TextButton(
              onPressed: onToggle,
              child: Text(showAll ? 'Ver menos' : 'Ver mais aulas'),
            ),
        ],
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ReportSession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final d = session.openedAt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final monthAbbr = ['JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ'][d.month - 1];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Column(
              children: [
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(monthAbbr, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.className, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(session.teacherName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.people, size: 14, color: Colors.green),
                const SizedBox(width: 2),
                Text('${session.presentCount}', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                const Icon(Icons.people_outline, size: 14, color: Colors.red),
                const SizedBox(width: 2),
                Text('${session.absentCount}', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AbsentStudentsSection extends StatelessWidget {
  final List<ReportStudentAbsence> students;
  const _AbsentStudentsSection({required this.students});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alunos com mais faltas no mês',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: students.map((s) => _AbsenceChip(student: s)).toList(),
          ),
        ),
      ],
    );
  }
}

class _AbsenceChip extends StatelessWidget {
  final ReportStudentAbsence student;
  const _AbsenceChip({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(student.studentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${student.absenceCount} faltas',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportButtons extends StatelessWidget {
  final VoidCallback onPdf;
  final VoidCallback onCsv;

  const _ExportButtons({required this.onPdf, required this.onCsv});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onPdf,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('Emitir Relatório (PDF)'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCsv,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Exportar (CSV)'),
          ),
        ),
      ],
    );
  }
}
