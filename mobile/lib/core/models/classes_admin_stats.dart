class ClassesAdminStats {
  final int total;

  ClassesAdminStats({required this.total});

  factory ClassesAdminStats.fromJson(Map<String, dynamic> json) {
    return ClassesAdminStats(total: json['total'] as int? ?? 0);
  }
}
