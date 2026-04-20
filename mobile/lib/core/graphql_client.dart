import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphqlClient {
  static Future<GraphQLClient> get() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token') ?? '';
    final tenantId = preferences.getString('tenant_id') ?? '';

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
