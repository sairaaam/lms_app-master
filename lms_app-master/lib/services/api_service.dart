import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://lms.gdcollege.ca/wp-json";
  final String customNamespace = "tutor-custom/v1";

  // Persistent storage for session data
  String? _token;
  Map<String, dynamic>? _userData;

  // Getter for user info used in Dashboard and Profile pages
  Map<String, dynamic>? get user => _userData;

  // Centralized headers to ensure the Authorization token is always sent
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

      debugPrint("Login Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token']; // Save token for future calls
        _userData = data; // Save user info for the UI
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
   * 2. DASHBOARD STATS (Total, Enrolled, Active)
   * ===================================================== */

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/dashboard-stats"),
        headers: _headers, // Token injected here
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'enrolled': data['enrolled'] ?? 0,
          'active': data['active'] ?? 0,
          'completed': data['completed'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint("Stats Error: $e");
    }
    return {'enrolled': 0, 'active': 0, 'completed': 0};
  }

  /* =====================================================
   * 3. COURSE LISTING (Enrolled Courses)
   * ===================================================== */

  Future<List<dynamic>> getEnrolledCourses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/enrolled-courses"),
        headers: _headers,
      );

      debugPrint("Courses Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Map the API 'courses' array to the UI list
        return data['courses'] ?? [];
      }
    } catch (e) {
      debugPrint("Course List Error: $e");
    }
    return [];
  }

  /* =====================================================
   * 4. CURRICULUM & LESSON CONTENT
   * ===================================================== */

  // Fetches topics and lesson IDs for a specific course
  Future<List<dynamic>> getCourseCurriculum(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/course-curriculum/$courseId"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['topics'] ?? []; // Returns nested list of topics/lessons
      }
    } catch (e) {
      debugPrint("Curriculum Fetch Error: $e");
    }
    return [];
  }

  // Fetches lesson text and the Gumlet Video ID
  Future<Map<String, dynamic>?> getLessonDetails(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$customNamespace/lesson/$lessonId"),
        headers: _headers,
      );

      // CRITICAL: Check your console for this output
      debugPrint("--- LOG START: LESSON $lessonId ---");
      debugPrint("RAW JSON: ${response.body}");
      debugPrint("--- LOG END ---");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['lesson'];
      }
    } catch (e) {
      debugPrint("Fetch Error for Lesson $lessonId: $e");
    }
    return null;
  }
  /* =====================================================
   * 5. MARK AS COMPLETE
   * ===================================================== */

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

// Single instance for the whole app
final apiService = ApiService();
