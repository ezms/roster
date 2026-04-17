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
}