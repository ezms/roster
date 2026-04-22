import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/graphql_client.dart';

class AccountRepository {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final client = await GraphqlClient.get();
    const mutation = r'''
      mutation ChangePassword($currentPassword: String!, $newPassword: String!) {
        changePassword(currentPassword: $currentPassword, newPassword: $newPassword)
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    ));

    if (result.hasException) {
      final message = result.exception?.graphqlErrors.firstOrNull?.message;
      throw Exception(message ?? 'Erro ao trocar senha');
    }
  }
}
