import 'package:flutter/material.dart';
import 'package:mobile/features/login/login_card_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          LoginCardWidget(),
        ],
      ),
    );
  }
}
