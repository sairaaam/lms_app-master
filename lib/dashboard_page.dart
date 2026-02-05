import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'enrolled_courses_page.dart';
import 'profile_page.dart'; // Ensure this file exists and is correct

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHomeContent(),
    const EnrolledCoursesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/GD-logo.png', height: 35),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6D391E),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends StatefulWidget {
  const DashboardHomeContent({super.key});
  @override
  State<DashboardHomeContent> createState() => _DashboardHomeContentState();
}

class _DashboardHomeContentState extends State<DashboardHomeContent> {
  Map<String, int> stats = {'enrolled': 0, 'active': 0, 'completed': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final res = await apiService.getDashboardStats();
    if (mounted) {
      setState(() {
        stats = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = apiService.user;
    String name = user?['user_display_name'] ?? "Student";

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Welcome back, $name",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _buildStatCard(
                    "Enrolled",
                    stats['enrolled']!,
                    Icons.collections_bookmark,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    "In Progress",
                    stats['active']!,
                    Icons.play_lesson,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    "Finished",
                    stats['completed']!,
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       color: const Color.fromARGB(255, 219, 197, 197).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}