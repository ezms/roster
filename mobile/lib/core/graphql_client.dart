import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/app_config.dart';

class GraphqlClient {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<GraphQLClient> get() async {
    final token = await _secure.read(key: 'auth_token') ?? '';
    final tenantId = await _secure.read(key: 'tenant_id') ?? '';

    final link = HttpLink(
      '${AppConfig.baseUrl}graphql',
      defaultHeaders: {
        'Authorization': 'Bearer $token',
        'X-Tenant-ID': tenantId,
      },
    );

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }
}
