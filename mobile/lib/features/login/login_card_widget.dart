import 'package:flutter/material.dart';
import 'package:mobile/features/login/login_controller.dart';

class LoginCardWidget extends StatefulWidget {
  const LoginCardWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LoginCardWidgetState();
}

class _LoginCardWidgetState extends State<LoginCardWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final LoginController _controller = LoginController();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success || !mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  if (_controller.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.shade100,
                      child: Text(
                        _controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 8),
                  child!,
                ],
              );
            },
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Obrigatório';
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("E-mail"),
                    hint: Text("Type your e-mail here... ex. user@mail.com"),
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  enabled: !_controller.isLoading,
                  onChanged: (_) => _controller.clearError(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Obrigatório';
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text("Password"),
                    hintText: "Type your password here...",
                  ),
                ),
                const SizedBox(height: 16),
                _controller.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text("Sign in"),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
