import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'course_details_page.dart';

class EnrolledCoursesPage extends StatefulWidget {
  const EnrolledCoursesPage({super.key});

  @override
  State<EnrolledCoursesPage> createState() => _EnrolledCoursesPageState();
}

class _EnrolledCoursesPageState extends State<EnrolledCoursesPage> {
  @override
  void initState() {
    super.initState();
    // Call debug when page loads
    apiService.debugEnrollment();
  }

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
          if (courses.isEmpty) {
            return const Center(child: Text("No courses found."));
          }

          return ListView.builder(
            itemCount: courses.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                child: ListTile(
                  leading: course['thumbnail'].isNotEmpty
                      ? Image.network(
                          course['thumbnail'],
                          width: 50,
                          errorBuilder: (c, e, s) => const Icon(Icons.book),
                        )
                      : const Icon(Icons.book),
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
