import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchAnnouncements,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                announcement['heading'] ?? 'No heading',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                formatDate(announcement['date'] ?? ''),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          announcement['content'] ?? 'No content',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade700,
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