import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/class/class_screen_controller.dart';
import 'package:mobile/features/class/widgets/student_list_card.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/repositories/student_repository.dart';

class StudentList extends StatefulWidget {
  final ClassSelectionController classSelectionController;

  const StudentList({super.key, required this.classSelectionController});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late final ClassScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClassScreenController(
      widget.classSelectionController,
      StudentRepository(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        widget.classSelectionController.selected == null
            ? 'Selecione uma turma para ver os alunos'
            : 'Nenhum aluno nesta turma',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _controller.students.length + (_controller.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _controller.students.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _controller.loading
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
                    onPressed: _controller.loadMore,
                    child: const Text('Carregar mais'),
                  ),
          );
        }
        return StudentListCard(student: _controller.students[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.students.isEmpty && _controller.loading) return _buildLoading();
        if (_controller.students.isEmpty) return _buildEmpty();
        return _buildList();
      },
    );
  }
}
