import 'package:dio/dio.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/models/school.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String _tokenKey = "auth_token";
  static const String _tenantKey = "tenant_id";

  static List<School> _schools = [];
  static List<School> get schools => _schools;

  Future<bool> login(final String email, final String password) async {
    try {
      final response = await _makeLoginRequest(email, password);
      if (response.statusCode != 200) return false;
      saveTokenPreference(response.data['token']);
      _schools = _mapSchoolsResponse(response.data['schools'] as List);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> selectSchool(School school) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tenantKey, school.id.toString());
  }

  Future<bool> checkAuthTokenPresent() async {
    return _checkPreferencePresent(_tokenKey);
  }

  Future<bool> checkAuthTenantIdPresent() async {
    return _checkPreferencePresent(_tenantKey);
  }

  Future<Response<dynamic>> _makeLoginRequest(
    final String email,
    final String password,
  ) async {
    return await HttpClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<void> saveTokenPreference(final String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  List<School> _mapSchoolsResponse(List<dynamic> schools) {
    return schools.map((school) => School.fromJson(school)).toList();
  }

  Future<bool> _checkPreferencePresent(String preference) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final String? storagedPreference = sharedPreferences.getString(preference);
    return storagedPreference != null && storagedPreference.isNotEmpty;
  }
}
