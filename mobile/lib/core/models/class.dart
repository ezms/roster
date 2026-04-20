class Class {
  final int id;
  final String name;

  Class({required this.id, required this.name});

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(id: json['id'], name: json['name']);
  }
}
