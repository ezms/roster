import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';
import 'package:mobile/core/models/student.dart';

const _studentFields = '''
  id
  name
  code
  photoUrl
  card {
    id
    version
    issuedAt
  }
  currentClass {
    id
    name
  }
''';

class StudentPage {
  final List<Student> students;
  final int total;
  final int page;
  final int lastPage;

  StudentPage({
    required this.students,
    required this.total,
    required this.page,
    required this.lastPage,
  });
}

class StudentRepository {
  Future<List<Student>> fetchAll() async {
    final client = await GraphqlClient.get();
    final query = '''
      query {
        students {
          $_studentFields
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) return [];
    return (result.data!['students'] as List).map((s) => Student.fromJson(s)).toList();
  }

  Future<Student> createStudent(String name) async {
    final client = await GraphqlClient.get();
    final mutation = '''
      mutation CreateStudent(\$input: CreateStudentInput!) {
        createStudent(input: \$input) {
          $_studentFields
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'input': {'name': name}},
    ));

    if (result.hasException) throw Exception('Falha ao criar aluno');
    return Student.fromJson(result.data!['createStudent']);
  }

  Future<Student> updateStudent(int id, String name) async {
    final client = await GraphqlClient.get();
    final mutation = '''
      mutation UpdateStudent(\$id: Int!, \$input: UpdateStudentInput!) {
        updateStudent(id: \$id, input: \$input) {
          $_studentFields
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'id': id, 'input': {'name': name}},
    ));

    if (result.hasException) throw Exception('Falha ao editar aluno');
    return Student.fromJson(result.data!['updateStudent']);
  }

  Future<bool> setStudentClass(int studentId, int? classId) async {
    final client = await GraphqlClient.get();
    const mutation = r'''
      mutation SetStudentClass($studentId: Int!, $classId: Int) {
        setStudentClass(studentId: $studentId, classId: $classId)
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'studentId': studentId, 'classId': classId},
    ));

    if (result.hasException) throw Exception('Falha ao vincular turma');
    return result.data!['setStudentClass'] ?? false;
  }

  Future<bool> deleteStudent(int id) async {
    final client = await GraphqlClient.get();
    const mutation = r'''
      mutation DeleteStudent($id: Int!) {
        deleteStudent(id: $id)
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'id': id},
    ));

    if (result.hasException) throw Exception('Falha ao excluir aluno');
    return result.data!['deleteStudent'] ?? false;
  }

  Future<StudentPage> fetchByClass({
    required int classId,
    required int page,
    int limit = 15,
  }) async {
    final client = await GraphqlClient.get();
    const query = r'''
      query StudentsByClass($classId: Int!, $page: Int!, $limit: Int!) {
        studentsByClass(classId: $classId, page: $page, limit: $limit) {
          students {
            id
            name
            code
            photoUrl
            card {
              id
              version
              issuedAt
            }
          }
          meta {
            total
            page
            lastPage
          }
        }
      }
    ''';

    final result = await client.query(QueryOptions(
      document: gql(query),
      variables: {'classId': classId, 'page': page, 'limit': limit},
    ));

    if (result.hasException) return StudentPage(students: [], total: 0, page: page, lastPage: page);

    final data = result.data!['studentsByClass'];
    final meta = data['meta'];

    return StudentPage(
      students: (data['students'] as List).map((s) => Student.fromJson(s)).toList(),
      total: meta['total'],
      page: meta['page'],
      lastPage: meta['lastPage'],
    );
  }
}
