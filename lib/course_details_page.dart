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

  final Color primaryBrown = const Color(0xFF6D391E);
  final Color headerFillColor = const Color(0xFFF3F4F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: "Categories: ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        TextSpan(
                          text: "Diploma Programs",
                          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://lms.gdcollege.ca/wp-content/uploads/2025/09/Makeup-Artist-Hair-Stylist-Banner-300x198.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Course Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBrown)),
                  const SizedBox(height: 6),
                  Container(height: 3, width: 90, color: primaryBrown),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Course Content", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),

            FutureBuilder<List<dynamic>>(
              future: apiService.getCourseCurriculum(courseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final topics = snapshot.data ?? [];

                // --- CRITICAL CHANGE: Create a flat list of all IDs for navigation ---
                List<int> allItemIds = [];
                for (var topic in topics) {
                  var items = topic['items'] as List? ?? [];
                  for (var item in items) {
                    allItemIds.add(int.parse(item['id'].toString()));
                  }
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final lessons = topic['items'] as List? ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          collapsedBackgroundColor: headerFillColor,
                          title: Text(
                            topic['topic_title'] ?? "Untitled Topic",
                            style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          children: lessons.map((item) {
                            return ListTile(
                              leading: Icon(
                                item['type'] == 'quiz' ? Icons.help_outline : Icons.play_circle_outline,
                                color: Colors.grey,
                              ),
                              title: Text(item['title']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => LessonPlayerPage(
                                      lessonId: int.parse(item['id'].toString()),
                                      allLessonIds: allItemIds, // Pass the list here
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}