import 'package:flutter/material.dart';

class LoginCardWidget extends StatefulWidget {
  const LoginCardWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LoginCardWidgetState();
}

class _LoginCardWidgetState extends State<LoginCardWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
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
                hint: Text("Type your e-mail here... ex. user@mail.com")
              ),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Obrigatório';
                return null;
              },
              decoration: InputDecoration(
                label: Text("Password"),
                hint: Text("Type your password here...")
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
              },
              child: Text("Sign in")),
          ],
        )
      );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
