import 'infographics.dart';
import 'package:flutter/material.dart';
import 'announcements_page.dart';
import 'videosPage.dart';
import 'articles_page.dart';
import 'journalPage.dart';
import 'dart:convert';
import 'taskPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'testimonials_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;
  String selectedTimeframe = 'Daily';
  final Map<String, Color> categoryColors = {
    'Pain Management': const Color(0xFF4A90E2),
    'Posture & Movement': const Color(0xFF50E3C2),
    'Healthy Habits': const Color(0xFFFFB74D),
  };
  final GlobalKey<State> _pieChartKey = GlobalKey();

  void _launchGoogleReview() async {
    final url = Uri.parse("https://www.yelp.com/biz/max-living-chiropractor-lexington-sc-lexington?osq=max+living+lexington&override_cta=Request+information");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToInfographics() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const InfoGraphicsPage())
    );
  }

  void _showTestimonials() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestimonialsPage()),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToInfographics,
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text('Infographics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchGoogleReview,
                  icon: const Icon(Icons.star_rounded),
                  label: const Text('Leave a Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showTestimonials,
              icon: const Icon(Icons.format_quote_rounded),
              label: const Text('Success Stories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      body: _selectedIndex == 2
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                        bottom: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: screenHeight * 0.035,
                            width: screenHeight * 0.035,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'max',
                            style: TextStyle(
                              fontSize: screenHeight * 0.035,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7890A2),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'living',
                            style: TextStyle(
                              fontSize: screenHeight * 0.035,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7890A2),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            'Announcements',
                            'View All',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AnnouncementsPage()),
                            ),
                          ),
                          const VerticalListSection(),
                          _buildSectionHeader(
                            context,
                            'Tasks Progress',
                            'View All',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TasksPage()),
                            ),
                          ),
                          _buildTasksProgressSection(),
                          _buildActionButtons(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [
                const ArticlesPage(),
                const TasksPage(),
                Container(),
                const VideosPage(),
                const SimpleJournalPage(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.blue.shade700,
              unselectedItemColor: Colors.grey.shade400,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: _selectedIndex,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 0 ? 8.0 : 4.0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0 ? Colors.blue.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_stories_rounded),
                  ),
                  label: 'Articles',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 1 ? 8.0 : 4.0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1 ? Colors.blue.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.checklist_rounded),
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _selectedIndex == 2
                            ? [Colors.blue.shade300, Colors.blue.shade500]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _selectedIndex == 2
                          ? [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 3 ? 8.0 : 4.0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 3 ? Colors.blue.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_circle_outline_rounded),
                  ),
                  label: 'Videos',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(_selectedIndex == 4 ? 8.0 : 4.0),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 4 ? Colors.blue.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.note_alt_rounded),
                  ),
                  label: 'Journal',
                ),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksProgressSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<SharedPreferences>(
        key: _pieChartKey,
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final prefs = snapshot.data!;
          final tasksJson = prefs.getStringList('tasks') ?? [];
          final tasks = tasksJson.isEmpty 
            ? [] 
            : tasksJson.map((e) => Task.fromJson(json.decode(e))).toList();

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _buildTimeframeButton('Daily', selectedTimeframe == 'Daily'),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: _buildTimeframeButton('Weekly', selectedTimeframe == 'Weekly'),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: _buildTimeframeButton('Monthly', selectedTimeframe == 'Monthly'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TasksPage()),
                    );
                    setState(() {
                      _pieChartKey.currentState?.setState(() {});
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: CustomPaint(
                      size: const Size(150, 150),
                      painter: ModernPieChartPainter(
                        categories: categoryColors.keys.toList(),
                        percentages: categoryColors.keys.map((category) {
                          if (tasks.isEmpty) return 0.0;
                          final categoryTasks = tasks.where((task) => task.category == category).toList();
                          if (categoryTasks.isEmpty) return 0.0;

                          final completedTasks = categoryTasks.where((task) {
                            if (!task.isCompleted || task.dateCompleted == null) return false;
                            
                            if (selectedTimeframe == 'Daily') {
                              final today = DateTime.now();
                              return task.dateCompleted!.year == today.year &&
                                     task.dateCompleted!.month == today.month &&
                                     task.dateCompleted!.day == today.day;
                            } else if (selectedTimeframe == 'Weekly') {
                              final now = DateTime.now();
                              final weekStart = now.subtract(Duration(days: now.weekday - 1));
                              return task.dateCompleted!.isAfter(weekStart.subtract(const Duration(days: 1)));
                            } else {
                              final now = DateTime.now();
                              final monthStart = DateTime(now.year, now.month, 1);
                              return task.dateCompleted!.isAfter(monthStart.subtract(const Duration(days: 1)));
                            }
                          }).length;

                          return (completedTasks / categoryTasks.length) * 100;
                        }).toList(),
                        colors: categoryColors.values.toList(),
                        selectedCategory: null,
                        animation: 1.0,
                        lastPercentages: Map.fromIterables(
                          categoryColors.keys,
                          categoryColors.keys.map((category) {
                            if (tasks.isEmpty) return 0.0;
                            final categoryTasks = tasks.where((task) => task.category == category).toList();
                            if (categoryTasks.isEmpty) return 0.0;
                            return categoryTasks.where((task) => task.isCompleted).length / categoryTasks.length * 100;
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeframeButton(String timeframe, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTimeframe = timeframe;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade700 : Colors.blue.shade50,
        foregroundColor: isSelected ? Colors.white : Colors.blue.shade700,
        elevation: isSelected ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(timeframe),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String actionText,
    VoidCallback onActionTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection(BuildContext context, bool isWide) {
    return SizedBox(
      height: isWide ? MediaQuery.of(context).size.height * 0.2 : MediaQuery.of(context).size.height * 0.15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: isWide ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      isWide ? 'Content ${index + 1}' : 'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerticalListSection extends StatefulWidget {
  const VerticalListSection({super.key});

  @override
  _VerticalListSectionState createState() => _VerticalListSectionState();
}

class _VerticalListSectionState extends State<VerticalListSection> {
  List<dynamic> announcements = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('https://max-living-test-o6arygu9k-bharaths-projects-dcb22d80.vercel.app/api/announcements'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        setState(() {
          announcements = decodedData;
          isLoading = false;
          error = null;
        });
      } else {
        throw Exception('Failed to load announcements: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
        announcements = [];
      });
      print('Error fetching announcements: $e');
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.22,
      child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: fetchAnnouncements,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : announcements.isEmpty
            ? const Center(child: Text('No announcements available'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                scrollDirection: Axis.vertical,
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: ListTile(
                      title: Text(
                        announcement['heading'] ?? 'No heading',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formatDate(announcement['date'] ?? ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}