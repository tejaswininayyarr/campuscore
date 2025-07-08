// This screen allows users to add a new goal or edit an existing one.
// It demonstrates Create and Update operations with Firestore.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'goal_model.dart'; // Import the Goal data model
import 'package:intl/intl.dart'; // Required for date formatting (ensure 'intl' is in pubspec.yaml)

class AddEditGoalScreen extends StatefulWidget {
  final Goal? goal; // Optional: If a Goal object is passed, it means we are editing an existing goal.

  AddEditGoalScreen({this.goal});

  @override
  _AddEditGoalScreenState createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey to validate the form
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text editing controllers for goal title and description
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate; // Stores the selected due date
  String _selectedStatus = 'pending'; // Stores the selected status, defaults to 'pending'
  bool _isSaving = false; // State to indicate if data is currently being saved
  String? _statusMessage; // Message to display to the user about save status

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state variables with existing goal data if in edit mode.
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _selectedDueDate = widget.goal?.dueDate;
    _selectedStatus = widget.goal?.status ?? 'pending';
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks when the widget is removed from the tree.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to open a date picker dialog and allow the user to select a due date.
  Future<void> _pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  // Create/Update: Function to save the goal data to Firestore.
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('You must be logged in to save a goal.', Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      Goal goalToSave = Goal(
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        status: _selectedStatus,
      );

      if (widget.goal == null) {
        // Create operation
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('goals')
            .add(goalToSave.toFirestore());
        _showSnackBar('Goal added successfully!', Colors.green);
      } else {
        // Update operation
        goalToSave.id = widget.goal!.id;
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('goals')
            .doc(goalToSave.id)
            .update(goalToSave.toFirestore());
        _showSnackBar('Goal updated successfully!', Colors.green);
      }
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving goal: $e');
      _showSnackBar('Failed to save goal. Please try again.', Colors.red);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Helper method to show a SnackBar message.
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add New Goal' : 'Edit Goal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Goal Title',
                          prefixIcon: Icon(Icons.title, color: Colors.blue),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title for your goal.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          prefixIcon: Icon(Icons.description, color: Colors.blue),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickDueDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: _selectedDueDate == null
                                  ? 'Select Due Date (Optional)'
                                  : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDueDate!)}',
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.info_outline, color: Colors.blue),
                        ),
                        items: <String>['pending', 'in_progress', 'completed']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.replaceAll('_', ' ').toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      _isSaving
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _saveGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                widget.goal == null ? 'Add Goal' : 'Update Goal',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                      if (_statusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _statusMessage!.contains('Error') ? Colors.red : Colors.green,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } 
}