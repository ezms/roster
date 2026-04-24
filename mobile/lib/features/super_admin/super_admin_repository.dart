import 'package:dio/dio.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/models/school.dart';

class SuperAdminUser {
  final int id;
  final String name;
  final String email;
  final String role;

  const SuperAdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory SuperAdminUser.fromJson(Map<String, dynamic> json) => SuperAdminUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}

class SuperAdminRepository {
  Future<List<School>> fetchSchools() async {
    final response = await HttpClient.get('/super/schools');
    return (response.data as List)
        .map((s) => School.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<School> createSchool(String name) async {
    final response = await HttpClient.post('/super/schools', data: {'name': name});
    return School.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteSchool(int id) async {
    await HttpClient.delete('/super/schools/$id');
  }

  Future<List<SuperAdminUser>> fetchUsers(int schoolId) async {
    final response = await HttpClient.get('/super/schools/$schoolId/users');
    return (response.data as List)
        .map((u) => SuperAdminUser.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<SuperAdminUser> createUser(
    int schoolId, {
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await HttpClient.post(
        '/super/schools/$schoolId/users',
        data: {'email': email, 'password': password, 'name': name, 'role': role},
      );
      return SuperAdminUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) throw const EmailAlreadyInUseError();
      rethrow;
    }
  }

  Future<void> deleteUser(int schoolId, int userId) async {
    await HttpClient.delete('/super/schools/$schoolId/users/$userId');
  }
}

class EmailAlreadyInUseError implements Exception {
  const EmailAlreadyInUseError();
}
