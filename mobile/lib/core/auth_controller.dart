import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/models/school.dart';

class AuthController {
  static const String _tokenKey = 'auth_token';
  static const String _tenantKey = 'tenant_id';
  static const String _schoolNameKey = 'school_name';
  static const String _platformRoleKey = 'platform_role';

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static List<School> _schools = [];
  static List<School> get schools => _schools;

  Future<bool> login(final String email, final String password) async {
    try {
      final response = await _makeLoginRequest(email, password);
      if (response.statusCode != 200) return false;
      await _secure.write(key: _tokenKey, value: response.data['token'] as String);
      _schools = _mapSchoolsResponse(response.data['schools'] as List);
      await _secure.write(
        key: _platformRoleKey,
        value: response.data['platformRole'] as String? ?? 'user',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIsSuperUser() async {
    return await _secure.read(key: _platformRoleKey) == 'super';
  }

  Future<void> selectSchool(School school) async {
    await _secure.write(key: _tenantKey, value: school.databaseHash);
    await _secure.write(key: _schoolNameKey, value: school.name);
  }

  Future<String?> getSchoolName() async {
    return _secure.read(key: _schoolNameKey);
  }

  Future<bool> checkAuthTokenPresent() async {
    final token = await _secure.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<bool> checkAuthTenantIdPresent() async {
    final tenant = await _secure.read(key: _tenantKey);
    return tenant != null && tenant.isNotEmpty;
  }

  Future<void> clearAll() async {
    await _secure.deleteAll();
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

  List<School> _mapSchoolsResponse(List<dynamic> schools) {
    return schools.map((school) => School.fromJson(school)).toList();
  }
}
