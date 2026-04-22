import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/core/models/classes_admin_stats.dart';

class ClassRepository {
  Future<List<Class>> fetchClasses() async {
    final client = await GraphqlClient.get();
    const query = r"""
      query {
        classes {
          id
          name
        }
      }
    """;

    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) return [];
    return (result.data?['classes'] as List)
        .map((c) => Class.fromJson(c))
        .toList();
  }

  Future<ClassesAdminStats> fetchAdminClassesStat() async {
    final client = await GraphqlClient.get();
    const query = r"""
      query GetClassesAdminDashboard {
        classesAdmin {
          total
          withoutTeacher
        }
      }
    """;

    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) throw Exception(result.exception.toString());
    
    final data = result.data?['classesAdmin'];
    if (data == null) {
      throw Exception('Dados administrativos não encontrados');
    }

    return ClassesAdminStats.fromJson(data);
  }

  Future<Class> createClass(String name) async {
    final client = await GraphqlClient.get();
    const mutation = r"""
      mutation CreateClass($input: CreateClassInput!) {
        createClass(input: $input) {
          id
          name
          createdAt
        }
      }
    """;

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {'name': name}
      },
    ));

    if (result.hasException) throw Exception('Falha ao criar turma');
    return Class.fromJson(result.data?['createClass']);
  }

  Future<Class> updateClass(int id, String name) async {
    final client = await GraphqlClient.get();
    const mutation = r"""
      mutation UpdateClass($id: Int!, $input: UpdateClassInput!) {
        updateClass(id: $id, input: $input) {
          id
          name
        }
      }
    """;

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'id': id,
        'input': {'name': name}
      },
    ));

    if (result.hasException) throw Exception('Falha ao editar turma');
    return Class.fromJson(result.data?['updateClass']);
  }

  Future<bool> deleteClass(int id) async {
    final client = await GraphqlClient.get();
    const mutation = r"""
      mutation DeleteClass($id: Int!) {
        deleteClass(id: $id)
      }
    """;

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'id': id},
    ));

    if (result.hasException) throw Exception('Falha ao deletar turma');
    return result.data?['deleteClass'] ?? false;
  }
}
