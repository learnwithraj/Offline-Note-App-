// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/notes_model.dart';

// class DatabaseService {
//   static final DatabaseService instance = DatabaseService._();
//   static Database? _database;

//   DatabaseService._();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     return openDatabase(
//       join(dbPath, 'notes.db'),
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT)',
//         );
//       },
//     );
//   }

//   Future<int> addNote(Note note) async {
//     final db = await database;
//     return db.insert('notes', note.toMap());
//   }

//   Future<List<Note>> getNotes() async {

//     final db = await database;
//     final notes = await db.query('notes');
//     return notes.map((note) => Note.fromMap(note)).toList();
//   }

//   Future<int> updateNote(Note note) async {
//     final db = await database;
//     return db
//         .update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
//   }

//   Future<int> deleteNote(int id) async {
//     final db = await database;
//     return db.delete('notes', where: 'id = ?', whereArgs: [id]);
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notes_app/models/notes_model.dart';

class DatabaseService {
  static Database? _database;

  // Initialize the database
  static Future<void> initDatabase() async {
    if (_database != null) return;

    String path = join(await getDatabasesPath(), 'notes_database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id TEXT PRIMARY KEY, 
            title TEXT, 
            content TEXT, 
            tags TEXT, 
            priority INTEGER, 
            color INTEGER, 
            createdAt TEXT, 
            lastEdited TEXT
          )
        ''');
      },
    );
  }

  // Fetch all notes
  static Future<List<Note>> fetchNotes() async {
    if (_database == null) throw Exception("Database not initialized");
    final List<Map<String, dynamic>> maps = await _database!.query('notes');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Add a note
  static Future<void> addNoteToDB(Note note) async {
    if (_database == null) throw Exception("Database not initialized");
    await _database!.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a note
  static Future<void> updateNoteInDB(Note note) async {
    if (_database == null) throw Exception("Database not initialized");
    await _database!.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  static Future<void> deleteNoteFromDB(String id) async {
    if (_database == null) throw Exception("Database not initialized");
    await _database!.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
