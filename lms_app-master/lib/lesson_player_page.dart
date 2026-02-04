import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_html/flutter_html.dart';
import 'services/api_service.dart';

class LessonPlayerPage extends StatefulWidget {
  final int lessonId;
  const LessonPlayerPage({super.key, required this.lessonId});

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  late Future<Map<String, dynamic>?> _lessonFuture;
  bool _isVideoLoading = true;

  @override
  void initState() {
    super.initState();
    // Cache the future to prevent WebView disposal on every rebuild
    _lessonFuture = apiService.getLessonDetails(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lesson Player"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Unable to load details."));
          }

          final data = snapshot.data!;
          final String itemType =
              data['type'] ?? 'lesson'; // Detects 'quiz' or 'lesson'
          final String videoId = data['video_id'] ?? '';
          final htmlContent = data['content'] ?? "";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP MEDIA SECTION ---
                if (itemType == 'quiz')
                  _buildQuizPlaceholder() // Show quiz UI if it's a quiz
                else if (videoId.isNotEmpty)
                  _buildVideoPlayer(videoId) // Show video player if ID exists
                else
                  const SizedBox.shrink(), // No top media if both are missing
                // --- CONTENT SECTION ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? "Untitled",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6D391E),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                      if (htmlContent.isNotEmpty)
                        Html(
                          data: htmlContent,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16.0),
                              lineHeight: const LineHeight(1.6),
                              color: Colors.black87,
                              margin: Margins.zero,
                            ),
                            "strong": Style(fontWeight: FontWeight.bold),
                          },
                        )
                      else if (itemType == 'quiz')
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("This quiz has no description."),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No description provided for this lesson.",
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildVideoPlayer(String videoId) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://play.gumlet.io/embed/$videoId"),
              headers: {
                // This MUST match one of the entries in your Gumlet Whitelist
                'Referer': 'https://lms.gdcollege.ca/',
                'Origin': 'https://lms.gdcollege.ca/',
              },
            ),
            initialSettings: InAppWebViewSettings(
              allowsInlineMediaPlayback: true,
              useHybridComposition: true,
              preferredContentMode: UserPreferredContentMode.MOBILE,
            ),
            onLoadStop: (controller, url) {
              if (mounted) setState(() => _isVideoLoading = false);
            },
          ),
          if (_isVideoLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: const Color(0xFF6D391E),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, color: Colors.white, size: 60),
            SizedBox(height: 12),
            Text(
              "Course Quiz",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "Please complete this quiz on the web platform.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
