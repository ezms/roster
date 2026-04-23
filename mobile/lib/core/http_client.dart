import 'package:dio/dio.dart';
import 'package:mobile/core/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Map<String, String>> _buildHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final tenant = prefs.getString('tenant_id');

    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (tenant != null && tenant.isNotEmpty) {
      headers['X-Tenant-ID'] = tenant;
    }
    return headers;
  }

  static Future<Response> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final headers = await _buildHeaders();
    return _dio.post(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    final headers = await _buildHeaders();
    return _dio.get(
      path,
      queryParameters: queryParams,
      options: Options(headers: headers),
    );
  }

  static Future<Response> delete(String path) async {
    final headers = await _buildHeaders();
    return _dio.delete(path, options: Options(headers: headers));
  }
}
