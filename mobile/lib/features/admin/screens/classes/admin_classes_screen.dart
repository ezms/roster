import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/admin/controllers/admin_classes_controller.dart';
import 'package:mobile/shared/controllers/school_controller.dart';
import 'package:mobile/shared/widgets/header.dart';
import 'package:mobile/shared/repositories/class_repository.dart';

class AdminClassesScreen extends StatefulWidget {
  final SchoolController schoolController;

  const AdminClassesScreen({super.key, required this.schoolController});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  late final AdminClassesController _classesController;

  @override
  void initState() {
    super.initState();
    _classesController = AdminClassesController(ClassRepository());
  }

  @override
  void dispose() {
    _classesController.dispose();
    super.dispose();
  }

  void _showCreateClassModal() {
    final nameController = TextEditingController();

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
                'Nova Turma',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Turma',
                  hintText: 'Ex: 3º Ano Ensino Médio',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final success = await _classesController.createClass(name);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro ao criar turma')),
                    );
                  }
                },
                child: const Text('Salvar', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
        onPressed: _showCreateClassModal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: ListenableBuilder(
        listenable: _classesController,
        builder: (context, _) {
          if (_classesController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_classesController.errorMessage != null) {
            return Center(child: Text(_classesController.errorMessage!));
          }

          final classes = _classesController.classes;

          if (classes.isEmpty) {
            return const Center(child: Text('Nenhuma turma cadastrada.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final turma = classes[index];
              return Card(
                child: ListTile(
                  title: Text(turma.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                    },
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