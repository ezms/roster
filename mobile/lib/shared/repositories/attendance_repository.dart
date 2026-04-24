import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';

class AttendanceRepository {
  Future<int> openOrGetSession(int classId) async {
    final client = await GraphqlClient.get();

    const currentQuery = r'''
      query {
        currentSession {
          id
          classId
        }
      }
    ''';

    final current = await client.query(QueryOptions(document: gql(currentQuery)));
    if (!current.hasException && current.data?['currentSession'] != null) {
      return current.data!['currentSession']['id'] as int;
    }

    const openMutation = r'''
      mutation OpenSession($classId: Int!) {
        openSession(classId: $classId) {
          id
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(openMutation),
      variables: {'classId': classId},
    ));

    if (result.hasException) throw Exception('Falha ao abrir sessão');
    return result.data!['openSession']['id'] as int;
  }

  Future<void> closeSession(int sessionId) async {
    final client = await GraphqlClient.get();

    const mutation = r'''
      mutation CloseSession($id: Int!) {
        closeSession(id: $id) {
          id
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'id': sessionId},
    ));

    if (result.hasException) throw Exception('Falha ao encerrar sessão');
  }

  Future<String> registerAttendance(String studentCode) async {
    final client = await GraphqlClient.get();

    const mutation = r'''
      mutation RegisterAttendance($studentCode: String!) {
        registerAttendance(studentCode: $studentCode) {
          student {
            name
          }
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'studentCode': studentCode},
    ));

    if (result.hasException) {
      final graphqlErrors = result.exception?.graphqlErrors ?? [];
      if (graphqlErrors.any((e) => e.message.contains('already registered'))) {
        throw const AlreadyRegisteredError();
      }
      if (graphqlErrors.any((e) => e.message.contains('not found'))) {
        throw const StudentNotFoundError();
      }
      if (graphqlErrors.isNotEmpty) throw const StudentNotFoundError();
      throw const CommunicationError();
    }

    return result.data!['registerAttendance']['student']['name'] as String;
  }
}

class AlreadyRegisteredError implements Exception {
  const AlreadyRegisteredError();
}

class StudentNotFoundError implements Exception {
  const StudentNotFoundError();
}

class CommunicationError implements Exception {
  const CommunicationError();
}
