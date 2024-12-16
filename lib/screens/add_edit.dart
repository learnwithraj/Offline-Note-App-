import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/models/notes_model.dart';
import 'package:notes_app/providers/theme_providers.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  // Controllers

  //  late quill.QuillController _contentController;
  final FocusNode _focusNode = FocusNode();

  late TextEditingController _titleController;
  late QuillController _contentController;
  late TextEditingController _tagController;

  // Note properties
  List<String> _tags = [];
  NotePriority _priority = NotePriority.low;
  Color _selectedColor = Colors.white;
  bool _hasUnsavedChanges = false;
  // Color palette
  final List<Color> _colorPalette = [
    Colors.white,
    Colors.red[100]!,
    Colors.blue[100]!,
    Colors.yellow[100]!,
    Colors.purple[100]!,
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = QuillController.basic(); // Initialize Quill controller

    _tagController = TextEditingController();
    _titleController.addListener(_checkForUnsavedChanges);
    _contentController.addListener(_checkForUnsavedChanges);

    // Initialize other properties if editing existing note
    if (widget.note != null) {
      _tags = widget.note!.tags ?? [];
      _priority = widget.note!.priority ?? NotePriority.low;
      _selectedColor = widget.note!.color ?? Colors.white;

      // Load existing content into QuillController
      final existingContent = widget.note!.content;
      _contentController = QuillController(
        document: Document.fromJson(
            existingContent.isNotEmpty ? jsonDecode(existingContent) : []),
        selection: TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();

    _titleController.removeListener(_checkForUnsavedChanges);
    _contentController.removeListener(_checkForUnsavedChanges);
    super.dispose();
  }

  void _saveNote() {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    // Create or update note
    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: jsonEncode(
          _contentController.document.toDelta().toJson()), // Save Quill content
      tags: _tags,
      priority: _priority,
      color: _selectedColor,
      createdAt: widget.note?.createdAt,
      lastEdited: DateTime.now(),
    );

    // Use provider to save the note
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (widget.note == null) {
      notesProvider.addNote(note);
    } else {
      notesProvider.updateNote(note);
    }

    // Navigate back
    Navigator.pop(context);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _checkForUnsavedChanges() {
    if (widget.note != null) {
      // Check for changes if editing an existing note
      _hasUnsavedChanges = _titleController.text != widget.note!.title ||
          jsonEncode(_contentController.document.toDelta().toJson()) !=
              widget.note!.content ||
          _tags != widget.note!.tags ||
          _priority != widget.note!.priority ||
          _selectedColor != widget.note!.color;
    } else {
      // Check if any field has content when creating a new note
      _hasUnsavedChanges = _titleController.text.trim().isNotEmpty ||
          !_contentController.document.isEmpty() ||
          _tags.isNotEmpty;
    }

    setState(() {}); // Update UI for leading button
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Create Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasUnsavedChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title TextField
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Content Quill Editor
            // Container(
            //   height: 250, // Adjust as needed
            //   child: QuillEditor(
            //     controller: _contentController,
            //     // readOnly: false,
            //     // autoFocus: true,
            //     // expands: false,
            //     // padding: EdgeInsets.all(10),
            //     focusNode: FocusNode(),
            //     scrollController: ScrollController(),
            //   ),
            // ),
            Container(
              height: 400,
              child: Column(
                children: [
                  QuillToolbar.simple(
                      controller: _contentController,
                      configurations: QuillSimpleToolbarConfigurations(
                        multiRowsDisplay: false,
                        showColorButton: true,
                        color: Colors.blueAccent.shade100,
                        toolbarSize: 35,
                      )),
                  SizedBox(height: 10),
                  // Expanded(
                  //   child: QuillEditor(
                  //     controller: _contentController,
                  //     focusNode: _focusNode,
                  //     scrollController: ScrollController(),
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.grey
                              : Colors.black, // Border color
                          width: 1, // Border width
                        ),
                        borderRadius: BorderRadius.circular(
                            8), // Optional: rounded corners
                      ),
                      child: QuillEditor(
                        controller: _contentController,
                        focusNode: _focusNode,
                        configurations: QuillEditorConfigurations(
                          padding: EdgeInsets.all(10),
                          placeholder: "Content",
                        ),
                        scrollController:
                            ScrollController(), // Padding inside the editor
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Tags Section
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ..._tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                    )),
                InputChip(
                  avatar: Icon(Icons.add),
                  label: Text('Add Tag'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AlertDialog(
                          // backgroundColor: Colors.white,
                          insetPadding: EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          title: Text('Add Tag'),
                          content: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              labelText: 'Tag Name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text('Add'),
                              onPressed: () {
                                _addTag();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Priority Selector
            Row(
              children: [
                Text('Priority:', style: TextStyle(fontSize: 16)),
                SizedBox(width: 16),
                DropdownButton<NotePriority>(
                  value: _priority,
                  onChanged: (NotePriority? newPriority) {
                    if (newPriority != null) {
                      setState(() {
                        _priority = newPriority;
                      });
                    }
                  },
                  items: NotePriority.values
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(_getPriorityText(priority)),
                          ))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Color Selector
            Row(
              children: [
                Text('Note Color:', style: TextStyle(fontSize: 16)),
                SizedBox(width: 16),
                ..._colorPalette.map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.red
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return 'High Priority';
      case NotePriority.medium:
        return 'Medium Priority';
      case NotePriority.low:
        return 'Low Priority';
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text('Discard Changes?'),
          content:
              Text('You have unsaved changes. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
