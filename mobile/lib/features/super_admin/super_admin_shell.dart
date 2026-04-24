import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/core/app_router.dart';
import 'package:mobile/core/models/school.dart';
import 'package:mobile/features/super_admin/super_admin_controller.dart';
import 'package:mobile/features/super_admin/super_admin_repository.dart';
import 'package:mobile/core/auth_controller.dart';

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

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({super.key});

  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  late final SuperAdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SuperAdminController(SuperAdminRepository());
  }

  Future<void> _logout() async {
    await AuthController().clearAll();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  void _showAddSchoolDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Escola'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: _inputDecoration('Nome da escola'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final school = await _controller.createSchool(name);
              messenger.showSnackBar(SnackBar(
                content: Text(school != null
                    ? 'Escola "${school.name}" criada com sucesso'
                    : 'Erro ao criar escola'),
              ));
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showUsersSheet(School school) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UsersSheet(school: school, controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administração da Plataforma'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_controller.errorMessage!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _controller.loadSchools,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          if (_controller.schools.isEmpty) {
            return const Center(child: Text('Nenhuma escola cadastrada.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.schools.length,
            itemBuilder: (context, index) {
              final school = _controller.schools[index];
              return _SchoolCard(
                school: school,
                onUsers: () => _showUsersSheet(school),
                onDelete: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir escola?'),
                      content: Text(
                        'Isso removerá "${school.name}" e todos os vínculos de usuários. '
                        'O banco de dados não será apagado automaticamente.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final ok = await _controller.deleteSchool(school.id);
                    messenger.showSnackBar(SnackBar(
                      content: Text(ok ? 'Escola removida' : 'Erro ao remover escola'),
                    ));
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSchoolDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final School school;
  final VoidCallback onUsers;
  final VoidCallback onDelete;

  const _SchoolCard({
    required this.school,
    required this.onUsers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    school.databaseHash,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onUsers,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              icon: const Icon(Icons.people, size: 18),
              label: const Text('Usuários'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersSheet extends StatefulWidget {
  final School school;
  final SuperAdminController controller;

  const _UsersSheet({required this.school, required this.controller});

  @override
  State<_UsersSheet> createState() => _UsersSheetState();
}

class _UsersSheetState extends State<_UsersSheet> {
  List<SuperAdminUser>? _users;
  bool _loading = true;

  static const _roles = ['admin', 'teacher', 'teacher_admin', 'secretary'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await widget.controller.fetchUsers(widget.school.id);
    if (mounted) setState(() { _users = users; _loading = false; });
  }

  void _showAddUserDialog() {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String selectedRole = 'admin';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text('Novo Usuário — ${widget.school.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: _inputDecoration('Nome'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  decoration: _inputDecoration('E-mail'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  decoration: _inputDecoration('Senha'),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: _inputDecoration('Função'),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final password = passwordCtrl.text.trim();
                if (name.isEmpty || email.isEmpty || password.isEmpty) return;
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final ok = await widget.controller.createUser(
                    widget.school.id,
                    name: name,
                    email: email,
                    password: password,
                    role: selectedRole,
                  );
                  if (ok) await _load();
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Usuário criado com sucesso')),
                    );
                  }
                } on EmailAlreadyInUseError {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('E-mail já está em uso por outra conta')),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Erro ao criar usuário')),
                  );
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Usuários — ${widget.school.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showAddUserDialog,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users == null || _users!.isEmpty
                    ? const Center(child: Text('Nenhum usuário cadastrado.'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _users!.length,
                        itemBuilder: (context, i) {
                          final user = _users![i];
                          return ListTile(
                            title: Text(user.name),
                            subtitle: Text('${user.email} · ${user.role}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                final ok = await widget.controller.deleteUser(
                                  widget.school.id,
                                  user.id,
                                );
                                if (ok) await _load();
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
