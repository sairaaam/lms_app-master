import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://lms.gdcollege.ca/wp-json";
  final String customNamespace = "tutor-custom/v1";

  String? _token;
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get user => _userData;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /* =====================================================
   * 1. AUTHENTICATION
   * ===================================================== */

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/jwt-auth/v1/token"),
        body: jsonEncode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userData = data;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    }
  }

  void logout() {
    _token = null;
    _userData = null;
  }

  /* =====================================================
   * 2. COURSE LISTING (Used for Dashboard Stats)
   * ===================================================== */

  Future<List<dynamic>> getEnrolledCourses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/enrolled-courses"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['courses'] ?? [];
      }
    } catch (e) {
      debugPrint("Course List Error: $e");
    }
    return [];
  }

  /* =====================================================
   * 3. PASSWORD RESET (Native API)
   * ===================================================== */

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse("https://lms.gdcollege.ca/wp-json/gd-college/v1/reset-password"),
        body: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /* =====================================================
   * 4. CURRICULUM & LESSONS
   * ===================================================== */

  Future<List<dynamic>> getCourseCurriculum(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/course-curriculum/$courseId"),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['topics'] ?? [];
      }
    } catch (e) {
      debugPrint("Curriculum Error: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getLessonDetails(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/lesson/$lessonId"),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['lesson'];
      }
    } catch (e) {
      debugPrint("Lesson Error: $e");
    }
    return null;
  }

  Future<bool> markLessonComplete(int lessonId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$customNamespace/lesson-complete"),
        headers: _headers,
        body: jsonEncode({'lesson_id': lessonId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      debugPrint("Completion Error: $e");
    }
    return false;
  }
}

final apiService = ApiService();