import 'package:mobile/core/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String _tokenKey = "auth_token";
  static const String _tenantKey = "tenant_id";

  Future<void> saveAuth(String token, String tenantId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
    await preferences.setString(_tenantKey, tenantId);
  }

  Future<bool> checkAuthTokenPresent() async {
    return _checkPreferencePresent(_tokenKey);
  }

  Future<bool> checkAuthTenantIdPresent() async {
    return _checkPreferencePresent(_tenantKey);
  }

  Future<bool> _checkPreferencePresent(String preference) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final String? storagedPreference = sharedPreferences.getString(preference);
    return storagedPreference != null && storagedPreference.isNotEmpty;
  }

  Future<bool> login(final String email, final String password) async {
    try {
      final response = await HttpClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode != 200) return false;

      final token = response.data['token'];
      final schools = response.data['schools'] as List;
      final tenantId = schools.isNotEmpty ? schools[0]['id'].toString() : null;
      await saveAuth(token, tenantId ?? '');
      return true;
    } catch (e) {
      return false;
    }
  }
}
