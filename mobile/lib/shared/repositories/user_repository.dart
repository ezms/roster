import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';
import 'package:mobile/core/models/user.dart';

class UserRepository {
  Future<User?> fetchMe() async {
    final client = await GraphqlClient.get();
    const query = r'''
      query {
        me {
          id
          name
          role
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException || result.data?['me'] == null) return null;
    return User.fromJson(result.data!['me']);
  }
}
