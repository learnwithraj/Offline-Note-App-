import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/models/notes_model.dart';
import 'package:notes_app/providers/theme_providers.dart';
import 'package:notes_app/screens/add_edit.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// Track the selected priority
  NotePriority? selectedPriority;
// Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Ensure database is initialized and notes are fetched
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      await notesProvider.init(); // Initialize the database and fetch notes
    });
  }

  final FocusNode _searchFocusNode = FocusNode();
  @override
  void dispose() {
    _searchController.dispose();

    _searchFocusNode.dispose();

    super.dispose();
  }

// Build filter chips for priority
// List<Widget> _buildPriorityFilters() {
//   return NotePriority.values.map((priority) {
//     return ChoiceChip(
//       label: Text(_getPriorityText(priority)),
//       selected: false, // Implement active state logic if needed
//       onSelected: (bool selected) {
//         // Implement filtering logic
//         setState(() {
//           // Update the selected priority
//           if (selected) {
//             selectedPriority = priority;
//           } else {
//             selectedPriority = null; // Optionally allow deselection
//           }
//         });
//       },
//     );
//   }).toList();
// }

  List<Widget> _buildPriorityFilters() {
    return NotePriority.values.map((priority) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ChoiceChip(
          label: Text(_getPriorityText(priority)),
          selected: selectedPriority ==
              priority, // Check if the current chip is selected
          onSelected: (bool selected) {
            setState(() {
              // Update the selected priority
              if (selected) {
                selectedPriority = priority;
              } else {
                selectedPriority = null; // Optionally allow deselection
              }
            });
          },
        ),
      );
    }).toList();
  }

// Get priority text
  String _getPriorityText(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return 'High';
      case NotePriority.medium:
        return 'Medium';
      case NotePriority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            key: ValueKey(themeProvider.isDarkMode),
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // Background color for the header
              ),
              child: Center(
                child: Text(
                  'Notes App', // Replace with your app name
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Menu Items

            ListTile(
              leading: Icon(Icons.note),
              title: Text('My Notes'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Notes
              },
            ),
            ListTile(
              leading: Icon(Icons.backup),
              title: Text('Backup'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Trash'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Rate the app'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Priority Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: _buildPriorityFilters(),
              ),
            ),
          ),

          // Notes List
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                // Apply search filter
                // final filteredNotes = _searchQuery.isEmpty
                //     ? notesProvider.notes
                //     : notesProvider.searchNotes(_searchQuery);

                List<Note> filteredNotes = notesProvider.notes;
                if (_searchQuery.isNotEmpty) {
                  filteredNotes = notesProvider.searchNotes(_searchQuery);
                }

                // Filter by priority if selected
                if (selectedPriority != null) {
                  filteredNotes =
                      notesProvider.getNotesByPriority(selectedPriority!);
                }

                // Loading state
                if (notesProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                // Empty state
                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notes found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Tap the + button to create a note',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Notes List
                return ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final dynamic content = note.content;

                    // Convert the List<dynamic> Delta format to plain text
                    final plainTextContent = quill.Document.fromJson(
                            List<Map<String, dynamic>>.from(
                                jsonDecode(content)))
                        .toPlainText();

                    return Dismissible(
                      key: Key(note.id ?? ''),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // Delete note
                        notesProvider.deleteNote(note.id!);
                      },
                      child: Card(
                        color: note.color ?? Colors.white,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plainTextContent,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Date: ${DateFormat('MMM dd, yyyy hh:mm a').format(note.createdAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: _getPriorityIcon(note.priority),
                          onTap: () {
                            // Navigate to edit screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditNoteScreen(note: note),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditNoteScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

// Get priority icon based on note priority
  Widget _getPriorityIcon(NotePriority? priority) {
    switch (priority) {
      case NotePriority.high:
        return Icon(Icons.error, color: Colors.red);
      case NotePriority.medium:
        return Icon(Icons.warning, color: Colors.orange);
      case NotePriority.low:
      default:
        return Icon(Icons.info_outline, color: Colors.blue);
    }
  }
}
