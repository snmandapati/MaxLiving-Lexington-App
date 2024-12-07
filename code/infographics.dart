import 'package:flutter/material.dart';

class InfoGraphicsPage extends StatelessWidget {
  const InfoGraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Infographics',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: infographics.length,
        itemBuilder: (context, index) {
          return InfographicCard(
            infographic: infographics[index],
            onTap: () => _showInfographic(context, index),
          );
        },
      ),
    );
  }

  void _showInfographic(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfographicViewerPage(
          infographics: infographics,
          initialIndex: index,
        ),
      ),
    );
  }
}

class InfographicCard extends StatelessWidget {
  final Infographic infographic;
  final VoidCallback onTap;

  const InfographicCard({
    super.key,
    required this.infographic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'infographic_${infographic.id}',
                  child: Image.asset(
                    infographic.assetPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infographic.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    infographic.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfographicViewerPage extends StatefulWidget {
  final List<Infographic> infographics;
  final int initialIndex;

  const InfographicViewerPage({
    super.key,
    required this.infographics,
    required this.initialIndex,
  });

  @override
  State<InfographicViewerPage> createState() => _InfographicViewerPageState();
}

class _InfographicViewerPageState extends State<InfographicViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.infographics[_currentIndex].title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.infographics.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Hero(
                  tag: 'infographic_${widget.infographics[index].id}',
                  child: Image.asset(
                    widget.infographics[index].assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.infographics.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Infographic {
  final String id;
  final String title;
  final String category;
  final String assetPath;

  const Infographic({
    required this.id,
    required this.title,
    required this.category,
    required this.assetPath,
  });
}

final List<Infographic> infographics = [
  Infographic(
    id: '1',
    title: 'Back Pain Prevention Tips',
    category: 'Pain Management',
    assetPath: 'assets/infographics/back_pain.png',
  ),
  Infographic(
    id: '2',
    title: 'Proper Posture Guide',
    category: 'Posture & Movement',
    assetPath: 'assets/infographics/posture_guide.png',
  ),
  // Add more infographics here
];