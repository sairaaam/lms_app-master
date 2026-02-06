import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'course_details_page.dart';

class EnrolledCoursesPage extends StatefulWidget {
  const EnrolledCoursesPage({super.key});

  @override
  State<EnrolledCoursesPage> createState() => _EnrolledCoursesPageState();
}

class _EnrolledCoursesPageState extends State<EnrolledCoursesPage> {
  // Theme colors consistent with your design
  final Color primaryBrown = const Color(0xFF6D391E);
  final Color backgroundWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Very light grey background
      appBar: AppBar(
        title: const Text(
          "In Progress Courses",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: primaryBrown,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getEnrolledCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryBrown));
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
              final double progress = double.tryParse(course['progress'].toString()) ?? 0.0;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => CourseDetailsPage(
                      courseId: course['id'],
                      title: course['title'],
                    ),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6D391E).withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Large Course Thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: course['thumbnail'] != null && course['thumbnail'].isNotEmpty
                            ? Image.network(
                                course['thumbnail'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),

                      // 2. Course Title Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Text(
                          course['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // 3. Progress Section (Matches image_65e95f.jpg)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey[200],
                                      color: primaryBrown,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "${progress.toInt()}% Complete",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
    );
  }
}