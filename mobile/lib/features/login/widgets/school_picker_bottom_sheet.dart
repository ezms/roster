import 'package:flutter/material.dart';
import 'package:mobile/core/models/school.dart';

class SchoolPickerBottomSheet extends StatelessWidget {
  final List<School> schools;
  final void Function(School) onSelected;

  const SchoolPickerBottomSheet({
    super.key,
    required this.schools,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Selecione a escola',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return ListTile(
                title: Text(school.name),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(school);
                },
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
