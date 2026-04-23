import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/core/models/student.dart';
import 'package:mobile/features/admin/controllers/admin_students_controller.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/repositories/student_repository.dart';
import 'package:mobile/shared/utils/student_card_pdf.dart';
import 'package:mobile/shared/widgets/header.dart';

class AdminStudentsScreen extends StatefulWidget {
  final SchoolController schoolController;
  final ClassSelectionController classSelectionController;

  const AdminStudentsScreen({
    super.key,
    required this.schoolController,
    required this.classSelectionController,
  });

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late final AdminStudentsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminStudentsController(StudentRepository(), widget.classSelectionController);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  void _showCreateModal() {
    final nameController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Novo Aluno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: _inputDecoration('Nome do Aluno', hint: 'Ex: João da Silva'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final success = await _controller.createStudent(name);

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Erro ao criar aluno')),
                    );
                  }
                },
                child: const Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditModal(int id, String currentName, Class? currentClass) {
    final nameController = TextEditingController(text: currentName);
    Class? selectedClass = currentClass;
    final classes = widget.classSelectionController.classes;
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Editar Aluno',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration('Nome do Aluno'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: _inputDecoration('Turma'),
                    child: DropdownButton<Class?>(
                      value: selectedClass,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sem turma')),
                        ...classes.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                        ),
                      ],
                      onChanged: (value) => setModalState(() => selectedClass = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final nameUpdated = await _controller.updateStudent(id, name);
                      final classUpdated = selectedClass?.id != currentClass?.id
                          ? await _controller.setStudentClass(id, selectedClass?.id)
                          : true;

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      if (!nameUpdated || !classUpdated) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Erro ao editar aluno')),
                        );
                      }
                    },
                    child: const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showActionsMenu(BuildContext context, Student student) {
    final messenger = ScaffoldMessenger.of(context);
    final hasCard = student.card != null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(hasCard ? 'Emitir Nova Via' : 'Emitir Carteirinha'),
              onTap: () async {
                Navigator.pop(context);
                final updated = await _controller.issueStudentCard(student.id);
                if (updated != null) {
                  await StudentCardPdf.print(updated, widget.schoolController.schoolName);
                } else if (context.mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Erro ao emitir carteirinha')),
                  );
                }
              },
            ),
            if (hasCard)
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text('Visualizar Carteirinha'),
                onTap: () async {
                  Navigator.pop(context);
                  await StudentCardPdf.print(student, widget.schoolController.schoolName);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _showEditModal(student.id, student.name, student.currentClass);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, student.id, student.name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Aluno'),
        content: Text('Tem certeza que deseja excluir "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _controller.deleteStudent(id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao excluir aluno')),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Header(
        controller: widget.schoolController,
        schoolName: () => widget.schoolController.schoolName,
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showCreateModal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
            return Center(child: Text(_controller.errorMessage!));
          }

          if (_controller.students.isEmpty) {
            return const Center(child: Text('Nenhum aluno cadastrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.students.length,
            itemBuilder: (context, index) {
              final student = _controller.students[index];
              return Card(
                child: ListTile(
                  title: Text(student.name),
                  subtitle: Text(
                    student.currentClass != null
                        ? '${student.code} · ${student.currentClass!.name}'
                        : student.code,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showActionsMenu(context, student),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
