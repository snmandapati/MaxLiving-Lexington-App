import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime dateCreated;
  final DateTime lastModified;
  final DateTime dateForEntry;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.lastModified,
    required this.dateForEntry,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'dateCreated': dateCreated.toIso8601String(),
    'lastModified': lastModified.toIso8601String(),
    'dateForEntry': dateForEntry.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    dateCreated: DateTime.parse(json['dateCreated']),
    lastModified: DateTime.parse(json['lastModified']),
    dateForEntry: DateTime.parse(json['dateForEntry']),
  );
}

class SimpleJournalPage extends StatefulWidget {
  const SimpleJournalPage({super.key});

  @override
  _SimpleJournalPageState createState() => _SimpleJournalPageState();
}

class _SimpleJournalPageState extends State<SimpleJournalPage> {
  List<Note> notes = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final _storage = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await _storage;
    final notesJson = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = notesJson
          .map((e) => Note.fromJson(json.decode(e)))
          .toList()
        ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await _storage;
    final notesJson = notes.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(selectedDate: _selectedDay),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        notes.add(result);
        notes.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      });
      await _saveNotes();
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          selectedDate: note.dateForEntry,
          existingNote: note,
        ),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        final index = notes.indexWhere((e) => e.id == note.id);
        notes[index] = result;
        notes.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      });
      await _saveNotes();
    }
  }

  void _deleteNote(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        notes.removeWhere((note) => note.id == id);
      });
      await _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesForSelectedDay = notes
        .where((note) => isSameDay(note.dateForEntry, _selectedDay))
        .toList()
      ..sort((a, b) => b.lastModified.compareTo(a.lastModified));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pain Journal',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              onPressed: _addNote,
              tooltip: 'Add New Note',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                return notes.where((note) => isSameDay(note.dateForEntry, day)).toList();
              },
            ),
          ),
          Expanded(
            child: notesForSelectedDay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No notes for ${DateFormat('MMM d, y').format(_selectedDay)}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addNote,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Note'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notesForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final note = notesForSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: Container(
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  note.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Last modified: ${DateFormat('MMM d, y h:mm a').format(note.lastModified)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _editNote(note),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Edit'),
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _editNote(note),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: const Text('Delete'),
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _deleteNote(note.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final DateTime selectedDate;
  final Note? existingNote;

  const NoteEditorPage({
    super.key,
    required this.selectedDate,
    this.existingNote,
  });

  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _contentController;
  String? _title;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.existingNote?.content);
  }

  Future<void> _saveNote() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    final title = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String tempTitle = widget.existingNote?.title ?? '';
        return AlertDialog(
          title: const Text('Enter Note Title'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            controller: TextEditingController(text: tempTitle),
            onChanged: (value) => tempTitle = value,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.of(context).pop(tempTitle),
            ),
          ],
        );
      },
    );

    if (title == null || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final note = Note(
      id: widget.existingNote?.id ?? DateTime.now().toString(),
      title: title,
      content: _contentController.text,
      dateCreated: widget.existingNote?.dateCreated ?? DateTime.now(),
      lastModified: DateTime.now(),
      dateForEntry: widget.selectedDate,
    );

    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote != null ? 'Edit Note' : 'New Note'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              onPressed: _saveNote,
              tooltip: 'Save Note',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'Start writing...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}