import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test"),),
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('Scanner'),
      ),
    );
  }
}
