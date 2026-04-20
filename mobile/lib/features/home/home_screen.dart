import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/home/home_controller.dart';
import 'package:mobile/shared/widgets/header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        controller: _controller,
        schoolName: () => _controller.schoolName,
      ),
      backgroundColor: AppColors.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
