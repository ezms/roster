class School {
  final int id;
  final String name;
  final String databaseHash;

  School({required this.id, required this.name, required this.databaseHash});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      name: json['name'],
      databaseHash: json['databaseHash'],
    );
  }
}
