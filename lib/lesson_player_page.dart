import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_html/flutter_html.dart';
import 'services/api_service.dart';

class LessonPlayerPage extends StatefulWidget {
  final int lessonId;
  final List<int> allLessonIds;

  const LessonPlayerPage({
    super.key, 
    required this.lessonId, 
    required this.allLessonIds,
  });

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  late Future<Map<String, dynamic>?> _lessonFuture;
  bool _isVideoLoading = true;
  final Color primaryBrown = const Color(0xFF6D391E);

  @override
  void initState() {
    super.initState();
    _loadLesson(widget.lessonId);
  }

  void _loadLesson(int id) {
    setState(() {
      _isVideoLoading = true;
      _lessonFuture = apiService.getLessonDetails(id);
    });
  }

  // Logic to handle marking the lesson as complete
  void _markLessonAsComplete() async {
    // Show feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing..."), duration: Duration(seconds: 1)),
    );

    // TODO: Add your API call here, e.g.:
    // await apiService.markLessonComplete(widget.lessonId);
    
    print("Lesson ${widget.lessonId} marked as complete.");
  }

  void _navigateToAdjacent(bool isNext) {
    int currentIndex = widget.allLessonIds.indexOf(widget.lessonId);
    int targetIndex = isNext ? currentIndex + 1 : currentIndex - 1;

    if (targetIndex >= 0 && targetIndex < widget.allLessonIds.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonPlayerPage(
            lessonId: widget.allLessonIds[targetIndex],
            allLessonIds: widget.allLessonIds,
          ),
        ),
      );
    } else {
      String message = isNext ? "You've reached the last lesson!" : "This is the first lesson!";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lesson Player", style: TextStyle(fontWeight: FontWeight.bold)),
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
          final String itemType = data['type'] ?? 'lesson';
          final String videoId = data['video_id'] ?? '';
          final String htmlContent = data['content'] ?? "";
          final double courseProgress = 10.0; // Placeholder progress value

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (itemType == 'quiz') _buildQuizPlaceholder() 
                      else if (videoId.isNotEmpty) _buildVideoPlayer(videoId)
                      else const SizedBox.shrink(),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['title'] ?? "Untitled", 
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBrown)),
                            const SizedBox(height: 15),
                            const Divider(),
                            if (htmlContent.isNotEmpty)
                              Html(
                                data: htmlContent,
                                style: {
                                  "body": Style(fontSize: FontSize(16.0), lineHeight: const LineHeight(1.6), color: Colors.black87, margin: Margins.zero),
                                  "strong": Style(fontWeight: FontWeight.bold, color: primaryBrown),
                                },
                              )
                            else
                              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No description provided.")),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section with Progress and Mark as Complete
              _buildBottomSection(courseProgress, videoId.isNotEmpty),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(double progress, bool hasVideo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nav Bar (Previous/Next)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: const Color(0xFFF1F1F1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavButton(Icons.arrow_back, "Previous", () => _navigateToAdjacent(false)),
                const SizedBox(width: 20),
                _buildNavButton(Icons.arrow_forward, "Next", () => _navigateToAdjacent(true), isNext: true),
              ],
            ),
          ),
          
          // Progress and Completion Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${progress.toInt()}% Complete", 
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100, 
                    backgroundColor: Colors.grey[200], 
                    color: primaryBrown, 
                    minHeight: 6
                  ),
                ),
                
                // Show "Mark as Complete" button only if the lesson has a video
                if (hasVideo) ...[
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _markLessonAsComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Mark as Complete", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onTap, {bool isNext = false}) {
    int currentIndex = widget.allLessonIds.indexOf(widget.lessonId);
    bool isDisabled = isNext 
        ? currentIndex >= widget.allLessonIds.length - 1 
        : currentIndex <= 0;

    return ElevatedButton(
      onPressed: isDisabled ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey[300] : (isNext ? const Color(0xFFE8DED6) : Colors.white),
        foregroundColor: Colors.black87,
        elevation: 0,
        side: isNext || isDisabled ? BorderSide.none : const BorderSide(color: Color(0xFFD1D1D1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isNext) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          if (isNext) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(String videoId) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://play.gumlet.io/embed/$videoId"),
              headers: {'Referer': 'https://lms.gdcollege.ca/', 'Origin': 'https://lms.gdcollege.ca/'},
            ),
            initialSettings: InAppWebViewSettings(allowsInlineMediaPlayback: true, useHybridComposition: true),
            onLoadStop: (controller, url) { if (mounted) setState(() => _isVideoLoading = false); },
          ),
          if (_isVideoLoading)
            Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildQuizPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: primaryBrown,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, color: Colors.white, size: 50),
            SizedBox(height: 10),
            Text("Course Quiz", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Complete this on the web portal", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}