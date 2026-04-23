import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';
import 'package:mobile/core/models/attendance_report.dart';
import 'package:mobile/core/models/user.dart';

class ReportsRepository {
  Future<List<User>> fetchTeachers() async {
    final client = await GraphqlClient.get();

    const query = r'''
      query {
        users {
          id
          name
          role
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) throw Exception('Falha ao carregar professores');

    final users = (result.data!['users'] as List)
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();

    return users.where((u) => u.role == 'teacher' || u.role == 'teacher_admin').toList();
  }

  Future<AttendanceReport> fetchReport({
    required int month,
    required int year,
    int? classId,
    int? teacherId,
  }) async {
    final client = await GraphqlClient.get();

    const query = r'''
      query AttendanceReport($month: Int!, $year: Int!, $classId: Int, $teacherId: Int) {
        attendanceReport(month: $month, year: $year, classId: $classId, teacherId: $teacherId) {
          summary {
            totalSessions
            totalPresences
            totalAbsences
            attendanceRate
          }
          sessions {
            id
            openedAt
            className
            teacherName
            presentCount
            absentCount
          }
          topAbsentStudents {
            studentId
            studentName
            absenceCount
          }
        }
      }
    ''';

    final result = await client.query(QueryOptions(
      document: gql(query),
      variables: {
        'month': month,
        'year': year,
        'classId': classId,
        'teacherId': teacherId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    if (result.hasException) throw Exception('Falha ao gerar relatório');

    return AttendanceReport.fromJson(
      result.data!['attendanceReport'] as Map<String, dynamic>,
    );
  }

  String buildCsv(AttendanceReport report, int month, int year) {
    final monthLabel = _monthName(month);
    final lines = <String>[
      'Relatório de Frequência - $monthLabel/$year',
      '',
      'Resumo',
      'Aulas,Presenças,Faltas,% Presença',
      '${report.summary.totalSessions},${report.summary.totalPresences},${report.summary.totalAbsences},${report.summary.attendanceRate.toStringAsFixed(0)}%',
      '',
      'Registros de Chamadas',
      'Data,Turma,Professor,Presenças,Faltas',
      ...report.sessions.map((s) {
        final d = s.openedAt.toLocal();
        final date =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        return '$date,"${s.className}","${s.teacherName}",${s.presentCount},${s.absentCount}';
      }),
    ];

    if (report.topAbsentStudents.isNotEmpty) {
      lines.addAll([
        '',
        'Alunos com Mais Faltas',
        'Aluno,Faltas',
        ...report.topAbsentStudents.map((s) => '"${s.studentName}",${s.absenceCount}'),
      ]);
    }

    return lines.join('\n');
  }

  String _monthName(int month) {
    const names = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    return names[month - 1];
  }
}
