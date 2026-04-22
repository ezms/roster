class StudentCard {
  final int id;
  final int version;
  final DateTime issuedAt;

  StudentCard({required this.id, required this.version, required this.issuedAt});

  factory StudentCard.fromJson(Map<String, dynamic> json) {
    return StudentCard(
      id: json['id'],
      version: json['version'],
      issuedAt: DateTime.parse(json['issuedAt']),
    );
  }
}
