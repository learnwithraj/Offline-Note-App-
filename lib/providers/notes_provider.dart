// import 'package:flutter/material.dart';
// import 'package:notes_app/models/notes_model.dart';
// import 'package:notes_app/services/database_services.dart';

// class NotesProvider with ChangeNotifier {
//   List<Note> _notes = [];

//   List<Note> get notes => _notes;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<void> fetchNotes() async {
//     _isLoading = true;
//     notifyListeners();
//     _notes = await DatabaseService.instance.getNotes();

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> addNote(Note note) async {
//     await DatabaseService.instance.addNote(note);
//     await fetchNotes();
//   }

//   Future<void> updateNote(Note note) async {
//     await DatabaseService.instance.updateNote(note);
//     await fetchNotes();
//   }

//   Future<void> deleteNote(int id) async {
//     await DatabaseService.instance.deleteNote(id);
//     await fetchNotes();
//   }
// }

import 'package:flutter/material.dart';
import 'package:notes_app/models/notes_model.dart';
import 'package:notes_app/services/database_services.dart';

// Enum for Note Priority
enum NotePriority { high, medium, low }

// Notes Provider
class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  // Initialize Database and Fetch Initial Notes
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await DatabaseService.initDatabase(); // Initialize the database
    await fetchNotes(); // Fetch notes after database is initialized
  }

  // Fetch All Notes
  Future<void> fetchNotes() async {
    try {
      _notes = await DatabaseService.fetchNotes();

      // Sort notes by last edited (most recent first)
      _notes.sort((a, b) => (b.lastEdited ?? DateTime.now())
          .compareTo(a.lastEdited ?? DateTime.now()));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching notes: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Note
  Future<void> addNote(Note note) async {
    try {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: note.title,
        content: note.content,
        tags: note.tags,
        priority: note.priority,
        color: note.color,
        createdAt: DateTime.now(),
        lastEdited: DateTime.now(),
      );

      await DatabaseService.addNoteToDB(newNote);
      await fetchNotes();
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  // Update Note
  Future<void> updateNote(Note note) async {
    try {
      await DatabaseService.updateNoteInDB(note);
      await fetchNotes();
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  // Delete Note
  Future<void> deleteNote(String id) async {
    try {
      await DatabaseService.deleteNoteFromDB(id);
      await fetchNotes();
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  // Filter Notes by Priority
  List<Note> getNotesByPriority(NotePriority priority) {
    return _notes.where((note) => note.priority == priority).toList();
  }

  // Filter Notes by Tag
  List<Note> getNotesByTag(String tag) {
    return _notes
        .where((note) => note.tags != null && note.tags!.contains(tag))
        .toList();
  }

  // Search Notes
  List<Note> searchNotes(String query) {
    query = query.toLowerCase();
    return _notes
        .where((note) =>
            note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            (note.tags != null &&
                note.tags!.any((tag) => tag.toLowerCase().contains(query))))
        .toList();
  }
}
