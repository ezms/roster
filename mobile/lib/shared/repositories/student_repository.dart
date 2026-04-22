import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';
import 'package:mobile/core/models/student.dart';

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
