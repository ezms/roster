import 'dart:io' as dart_io;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/app_config.dart';
import 'package:mobile/core/app_router.dart';
import 'package:mobile/core/auth_controller.dart';

class HttpClient {
  static final Dio _dio = _buildDio();

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = dart_io.HttpClient();
      client.badCertificateCallback = (cert, host, port) => false;
      return client;
    };

    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await AuthController().clearAll();
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<Map<String, String>> _buildHeaders() async {
    final token = await _secure.read(key: 'auth_token') ?? '';
    final tenant = await _secure.read(key: 'tenant_id');

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
