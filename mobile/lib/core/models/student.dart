import 'package:mobile/core/models/student_card.dart';

class Student {
  final int id;
  final String name;
  final String code;
  final String? photoUrl;
  final StudentCard? card;

  Student({
    required this.id,
    required this.name,
    required this.code,
    this.photoUrl,
    this.card,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      photoUrl: json['photoUrl'],
      card: json['card'] != null ? StudentCard.fromJson(json['card']) : null,
    );
  }
}
