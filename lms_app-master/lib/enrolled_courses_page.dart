// lib/enrolled_courses_page.dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'course_details_page.dart';

class EnrolledCoursesPage extends StatelessWidget {
  const EnrolledCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Courses")),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getEnrolledCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data ?? [];
          if (courses.isEmpty)
            return const Center(child: Text("No courses found."));

          return ListView.builder(
            itemCount: courses.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    course['thumbnail'],
                    width: 50,
                    errorBuilder: (c, e, s) => Icon(Icons.book),
                  ),
                  title: Text(course['title']),
                  subtitle: Text("Progress: ${course['progress']}%"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => CourseDetailsPage(
                        courseId: course['id'],
                        title: course['title'],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
