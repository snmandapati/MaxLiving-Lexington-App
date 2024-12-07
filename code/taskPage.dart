import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

class Task {
  String id;
  String name;
  bool isCompleted;
  DateTime? dateCompleted;
  String category;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.dateCompleted,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isCompleted': isCompleted,
    'dateCompleted': dateCompleted?.toIso8601String(),
    'category': category,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    name: json['name'],
    isCompleted: json['isCompleted'] ?? false,
    dateCompleted: json['dateCompleted'] != null 
        ? DateTime.parse(json['dateCompleted'])
        : null,
    category: json['category'],
  );
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  List<Task> tasks = [];
  String selectedTimeframe = 'Daily';
  String? selectedCategory;
  final Map<String, GlobalKey> expansionTileKeys = {};
  final _storage = SharedPreferences.getInstance();
  late AnimationController _animationController;
  Map<String, double> lastPercentages = {};
  final Map<String, bool> categoryExpanded = {};

  final Map<String, Color> categoryColors = {
    'Pain Management': const Color(0xFF4A90E2),       // Blue
    'Posture & Movement': const Color(0xFF50E3C2),    // Teal
    'Healthy Habits': const Color(0xFFFFB74D),        // Orange
  };

  final Map<String, List<String>> categoryTasks = {
    'Pain Management': [
      'Do recommended stretches/exercises',
      'Use heat or ice as needed',
      'Track pain levels for changes',
      'Take regular breaks to avoid strain'
    ],
    'Posture & Movement': [
      'Keep good posture during activities',
      'Set up an ergonomic workspace',
      'Stretch every 30-60 minutes',
      'Use safe lifting techniques'
    ],
    'Healthy Habits': [
      'Drink 8+ glasses of water daily',
      'Eat balanced meals for joint health',
      'Avoid back/neck strain activities',
      'Practice mindfulness to relax'
    ],
  };

  String getCategoryFromAngle(double angle) {
    // Normalize angle to 0-360 range
    angle = (angle + 360) % 360;
    
    // Define sector ranges (120° each, starting from -30°)
    if (angle >= 330 || angle < 90) {
      return 'Pain Management';      // Top sector (-30° to 90°)
    } else if (angle >= 90 && angle < 210) {
      return 'Healthy Habits';       // Bottom right sector (90° to 210°)
    } else {
      return 'Posture & Movement';   // Bottom left sector (210° to 330°)
    }
  }

  @override
  void initState() {
    super.initState();
    for (var category in categoryColors.keys) {
      expansionTileKeys[category] = GlobalKey();
      categoryExpanded[category] = false;
    }
    _loadTasks();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  String getTimeframeSubtitle() {
    switch (selectedTimeframe) {
      case 'Daily':
        return DateFormat('MMMM d, yyyy').format(DateTime.now());
      case 'Weekly':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}';
      case 'Monthly':
        return DateFormat('MMMM yyyy').format(DateTime.now());
      default:
        return '';
    }
  }

  void _toggleCategory(String? category) {
    setState(() {
      selectedCategory = selectedCategory == category ? null : category;
      if (category != null) {
        categoryExpanded[category] = !categoryExpanded[category]!;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await _storage;
    final tasksJson = prefs.getStringList('tasks') ?? [];
    
    if (tasksJson.isEmpty) {
      _initializeDefaultTasks();
    } else {
      setState(() {
        tasks = tasksJson.map((e) => Task.fromJson(json.decode(e))).toList();
        _updateLastPercentages();
      });
    }
  }

  void _initializeDefaultTasks() {
    List<Task> defaultTasks = [];
    categoryTasks.forEach((category, taskNames) {
      for (var taskName in taskNames) {
        defaultTasks.add(Task(
          id: '${category}_${taskName}_${DateTime.now().millisecondsSinceEpoch}',
          name: taskName,
          isCompleted: false,
          dateCompleted: null,
          category: category,
        ));
      }
    });

    setState(() {
      tasks = defaultTasks;
    });
    _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await _storage;
    final tasksJson = tasks.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _updateLastPercentages() {
    for (var category in categoryColors.keys) {
      lastPercentages[category] = _calculateCategoryCompletion(category);
    }
  }

  double _calculateCategoryCompletion(String category) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Daily Tasks',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [

          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<String>(
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  'Daily',
                  'Weekly',
                  'Monthly'
                ].map((String value) => PopupMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == selectedTimeframe
                          ? Colors.blue.shade700
                          : Colors.black87,
                      fontWeight: value == selectedTimeframe
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                )).toList(),
                onSelected: (String newValue) {
                  setState(() {
                    selectedTimeframe = newValue;
                    _updateLastPercentages();
                    _animationController.forward(from: 0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        selectedTimeframe,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pie Chart Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$selectedTimeframe Progress',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getTimeframeSubtitle(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (selectedCategory != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      selectedCategory!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: categoryColors[selectedCategory],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: GestureDetector(
                          onTapUp: (TapUpDetails details) {
                            final RenderBox box = context.findRenderObject() as RenderBox;
                            final Offset localPosition = box.globalToLocal(details.globalPosition);
                            final Offset center = Offset(
                              box.size.width / 2,
                              box.size.height / 2,
                            );
                            
                            final double distance = (localPosition - center).distance;
                            final double maxRadius = min(box.size.width, box.size.height) * 0.4;
                            
                            if (distance > maxRadius) {
                              setState(() {
                                selectedCategory = null;
                                categoryExpanded.forEach((key, value) {
                                  categoryExpanded[key] = false;
                                });
                              });
                              return;
                            }
                            
                            final double dx = localPosition.dx - center.dx;
                            final double dy = localPosition.dy - center.dy;
                            final double angle = (atan2(dy, dx) * 180 / pi) + 90;
                            
                            final clickedCategory = getCategoryFromAngle(angle);
                            setState(() {
                              if (selectedCategory == clickedCategory) {
                                selectedCategory = null;
                                categoryExpanded[clickedCategory] = false;
                              } else {
                                selectedCategory = clickedCategory;
                                categoryExpanded[clickedCategory] = true;
                                expansionTileKeys[clickedCategory] = GlobalKey();
                              }
                            });
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: ModernPieChartPainter(
                              categories: categoryColors.keys.toList(),
                              percentages: categoryColors.keys
                                  .map((category) => _calculateCategoryCompletion(category))
                                  .toList(),
                              colors: categoryColors.values.toList(),
                              selectedCategory: selectedCategory,
                              animation: _animationController.value,
                              lastPercentages: lastPercentages,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 100,
                ),
                itemCount: categoryColors.length,
                itemBuilder: (context, index) {
                  final category = categoryColors.keys.elementAt(index);
                  final color = categoryColors[category]!;
                  final categoryTasksList = tasks
                      .where((task) => task.category == category)
                      .toList()
                    ..sort((a, b) => a.isCompleted ? 1 : -1);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(selectedCategory == category ? 0.2 : 0.1),
                          blurRadius: selectedCategory == category ? 12 : 8,
                          offset: Offset(0, selectedCategory == category ? 6 : 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ExpansionTile(
                        key: expansionTileKeys[category],
                        initiallyExpanded: categoryExpanded[category] ?? false,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            categoryExpanded[category] = expanded;
                            if (expanded) {
                              selectedCategory = category;
                            } else if (selectedCategory == category) {
                              selectedCategory = null;
                            }
                          });
                        },
                        trailing: Container(
                          width: 65,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${_calculateCategoryCompletion(category).round()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryTasksList.length,
                            itemBuilder: (context, taskIndex) {
                              final task = categoryTasksList[taskIndex];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: task.isCompleted 
                                      ? color.withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: task.isCompleted
                                        ? color.withOpacity(0.3)
                                        : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    task.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: task.isCompleted
                                          ? color.withOpacity(0.8)
                                          : Colors.black87,
                                      fontWeight: task.isCompleted
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  value: task.isCompleted,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _updateLastPercentages();
                                      task.isCompleted = value ?? false;
                                      task.dateCompleted = value ?? false 
                                          ? DateTime.now() 
                                          : null;
                                      _animationController.forward(from: 0);
                                    });
                                    _saveTasks();
                                  },
                                  activeColor: color,
                                  checkColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernPieChartPainter extends CustomPainter {
  final List<String> categories;
  final List<double> percentages;
  final List<Color> colors;
  final String? selectedCategory;
  final double animation;
  final Map<String, double> lastPercentages;

  ModernPieChartPainter({
    required this.categories,
    required this.percentages,
    required this.colors,
    this.selectedCategory,
    required this.animation,
    required this.lastPercentages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.8 / 2;
    const double startAngle = -pi / 2;  // Start from top
    const double sectorAngle = 2 * pi / 3;
    const double spacing = 0.07;

    // Draw sectors in specific order
    final orderedCategories = [
      'Pain Management',        // Top
      'Posture & Movement',     // Bottom left
      'Healthy Habits'          // Bottom right
    ];
    
    for (int i = 0; i < orderedCategories.length; i++) {
      final category = orderedCategories[i];
      final categoryIndex = categories.indexOf(category);
      final bool isSelected = selectedCategory == category;
      
      // Calculate angles based on position
      double currentStartAngle;
      if (category == 'Pain Management') {
        currentStartAngle = -pi / 2; // Top position
      } else if (category == 'Posture & Movement') {
        currentStartAngle = 5 * pi / 6; // Bottom left
      } else { // Healthy Habits
        currentStartAngle = pi / 6; // Bottom right
      }

      // Calculate animated progress
      final lastPercentage = lastPercentages[category] ?? 0.0;
      final currentPercentage = percentages[categoryIndex];
      final progress = (lastPercentage + (currentPercentage - lastPercentage) * animation) / 100;

      // Add elevation effect for selected sector
      if (isSelected) {
        final shadowPaint = Paint()
          ..color = colors[categoryIndex].withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + 4),
          currentStartAngle,
          sectorAngle,
          true,
          shadowPaint,
        );
      }

      // Draw background arc (empty state)
      final backgroundPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.2
        ..color = Colors.grey[200]!;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentStartAngle + (spacing / 2),
        sectorAngle - spacing,
        false,
        backgroundPaint,
      );

      // Draw filled arc if there's progress
      if (progress > 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * (isSelected ? 0.22 : 0.2)
          ..color = colors[categoryIndex]
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentStartAngle + (spacing / 2),
          (sectorAngle - spacing) * progress,
          false,
          paint,
        );
      }

      // Draw percentage label
      final labelAngle = currentStartAngle + (sectorAngle / 2);
      final labelRadius = radius * 1.3;
      final labelX = center.dx + labelRadius * cos(labelAngle);
      final labelY = center.dy + labelRadius * sin(labelAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${currentPercentage.round()}%',
          style: TextStyle(
            color: isSelected ? colors[categoryIndex] : Colors.grey[600],
            fontSize: isSelected ? 16 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelX - textPainter.width / 2,
          labelY - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(ModernPieChartPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.selectedCategory != selectedCategory ||
      !mapEquals(oldDelegate.lastPercentages, lastPercentages) ||
      !listEquals(oldDelegate.percentages, percentages);
}