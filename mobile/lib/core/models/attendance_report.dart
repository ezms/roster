class ReportSummary {
  final int totalSessions;
  final int totalPresences;
  final int totalAbsences;
  final double attendanceRate;

  const ReportSummary({
    required this.totalSessions,
    required this.totalPresences,
    required this.totalAbsences,
    required this.attendanceRate,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        totalSessions: json['totalSessions'] as int,
        totalPresences: json['totalPresences'] as int,
        totalAbsences: json['totalAbsences'] as int,
        attendanceRate: (json['attendanceRate'] as num).toDouble(),
      );
}

class ReportSession {
  final int id;
  final DateTime openedAt;
  final String className;
  final String teacherName;
  final int presentCount;
  final int absentCount;

  const ReportSession({
    required this.id,
    required this.openedAt,
    required this.className,
    required this.teacherName,
    required this.presentCount,
    required this.absentCount,
  });

  factory ReportSession.fromJson(Map<String, dynamic> json) => ReportSession(
        id: json['id'] as int,
        openedAt: DateTime.parse(json['openedAt'] as String),
        className: json['className'] as String,
        teacherName: json['teacherName'] as String,
        presentCount: json['presentCount'] as int,
        absentCount: json['absentCount'] as int,
      );
}

class ReportStudentAbsence {
  final int studentId;
  final String studentName;
  final int absenceCount;

  const ReportStudentAbsence({
    required this.studentId,
    required this.studentName,
    required this.absenceCount,
  });

  factory ReportStudentAbsence.fromJson(Map<String, dynamic> json) => ReportStudentAbsence(
        studentId: json['studentId'] as int,
        studentName: json['studentName'] as String,
        absenceCount: json['absenceCount'] as int,
      );
}

class AttendanceReport {
  final ReportSummary summary;
  final List<ReportSession> sessions;
  final List<ReportStudentAbsence> topAbsentStudents;

  const AttendanceReport({
    required this.summary,
    required this.sessions,
    required this.topAbsentStudents,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) => AttendanceReport(
        summary: ReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
        sessions: (json['sessions'] as List)
            .map((s) => ReportSession.fromJson(s as Map<String, dynamic>))
            .toList(),
        topAbsentStudents: (json['topAbsentStudents'] as List)
            .map((s) => ReportStudentAbsence.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
