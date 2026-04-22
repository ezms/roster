class ClassesAdminStats {
  final int total;
  final int withoutTeacher;

  ClassesAdminStats({
    required this.total,
    required this.withoutTeacher,
  });

  factory ClassesAdminStats.fromJson(Map<String, dynamic> json) {
    return ClassesAdminStats(
      total: json['total'] as int? ?? 0, 
      withoutTeacher: json['withoutTeacher'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'withoutTeacher': withoutTeacher,
    };
  }
}
