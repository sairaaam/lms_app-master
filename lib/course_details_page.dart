import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'lesson_player_page.dart';

class CourseDetailsPage extends StatelessWidget {
  final int courseId;
  final String title;
  const CourseDetailsPage({
    super.key,
    required this.courseId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getCourseCurriculum(courseId),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }
          final topics = snapshot.data!;

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ExpansionTile(
                title: Text(
                  topic['topic_title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: (topic['items'] as List).map((item) {
                  return ListTile(
                    leading: const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF6D391E),
                    ),
                    title: Text(item['title']),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => LessonPlayerPage(lessonId: item['id']),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}