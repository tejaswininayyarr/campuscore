// This screen displays a list of goals and allows users to add, edit, 
// and delete them. 
// It demonstrates real-time data fetching (Read) and Delete operations.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'goal_model.dart'; // Import the Goal data model

class GoalTaskManagerScreen extends StatefulWidget {
  @override
  _GoalTaskManagerScreenState createState() => _GoalTaskManagerScreenState();
}

class _GoalTaskManagerScreenState extends State<GoalTaskManagerScreen> {
  // Firebase instances for authentication and Firestore database
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser; // Holds the currently authenticated user

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Get the current user when the screen initializes
    if (_currentUser == null) {
      // If no user is logged in, navigate them back to the login screen.
      // `addPostFrameCallback` ensures this navigation happens after the widget tree is built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  // Delete: Function to delete a goal from Firestore
  // This function now only performs the deletion and shows a snackbar,
  // as the confirmation dialog is handled by the `confirmDismiss` callback.
  Future<void> _performDeleteGoal(String goalId) async {
    if (_currentUser == null) return; // Ensure a user is logged in before attempting to delete

    try {
      // Access the 'goals' sub-collection under the current user's document and delete the specific goal.
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('goals')
          .doc(goalId)
          .delete();
      _showSnackBar('Goal deleted successfully!', Colors.green); // Show success message
    } catch (e) {
      // Catch and print any errors during deletion
      print('Error deleting goal: $e');
      _showSnackBar('Failed to delete goal. Please try again.', Colors.red); // Show error message
    }
  }

  // Helper method to show a SnackBar message (e.g., success or error notifications)
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2), // How long the snackbar is visible
        behavior: SnackBarBehavior.floating, // Makes the snackbar float above content
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for snackbar
        margin: EdgeInsets.all(10), // Margin around the snackbar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, display a simple message and return early
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Goal Manager')),
        body: Center(child: Text('Please log in to manage your goals.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals & Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Read: StreamBuilder listens for real-time updates to the user's goals from Firestore.
        // It queries the 'goals' sub-collection under the current user's document and orders them by creation time.
        stream: _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('goals')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Show a loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // If there's an error in the stream, display an error message
          if (snapshot.hasError) {
            print('Error fetching goals: ${snapshot.error}');
            return Center(child: Text('Error loading goals: ${snapshot.error}'));
          }
          // If no goals are found or the list is empty, display a friendly message
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 80, color: Colors.grey.shade400), // Large task icon
                    SizedBox(height: 20),
                    Text(
                      'No goals yet! Tap the + button to add your first goal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          // Convert the list of Firestore documents into a list of Goal objects
          List<Goal> goals = snapshot.data!.docs.map((doc) => Goal.fromFirestore(doc)).toList();

          // Display the list of goals using a ListView.builder
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              Goal goal = goals[index];
              // Dynamically update the goal's status to 'overdue' if its due date has passed and it's not completed.
              if (goal.status != 'completed' &&
                  goal.dueDate != null &&
                  goal.dueDate!.isBefore(DateTime.now())) {
                goal.status = 'overdue';
              }

              // Dismissible widget allows swiping to delete a goal
              return Dismissible(
                key: Key(goal.id!), // Unique key for each dismissible item (Firestore document ID)
                direction: DismissDirection.endToStart, // Allow swiping from right to left
                background: Container(
                  color: Colors.red.shade700, // Red background when swiping for delete
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white), // Delete icon
                ),
                // The `confirmDismiss` callback now correctly returns Future<bool?>
                confirmDismiss: (direction) async {
                  // Show confirmation dialog before actually dismissing (deleting) the item
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text('Confirm Delete'),
                        content: Text('Are you sure you want to delete this goal? This action cannot be undone.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              Navigator.of(context).pop(false); // User cancelled, return false
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                            child: Text('Delete', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop(true); // User confirmed, return true
                            },
                          ),
                        ],
                      );
                    },
                  );
                  // If user confirmed (confirm is true), perform the deletion and return true to dismiss.
                  // Otherwise, return false to prevent dismissal.
                  if (confirm == true) {
                    await _performDeleteGoal(goal.id!); // Call the actual delete function
                    return true;
                  }
                  return false;
                },
                child: Card(
                  elevation: 6, // Shadow for the goal card
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: EdgeInsets.symmetric(vertical: 8), // Vertical margin between cards
                  child: InkWell(
                    // Makes the card tappable for editing
                    onTap: () {
                      // Navigate to AddEditGoalScreen for editing, passing the current Goal object as arguments
                      Navigator.of(context).pushNamed(
                        '/add_edit_goal',
                        arguments: goal,
                      );
                    },
                    borderRadius: BorderRadius.circular(16), // Match InkWell's ripple to card shape
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(goal.statusIcon, color: goal.statusColor, size: 24), // Display status icon with color
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                    // Apply strikethrough if the goal is completed
                                    decoration: goal.status == 'completed' ? TextDecoration.lineThrough : null,
                                    decorationColor: Colors.grey,
                                  ),
                                ),
                              ),
                              // Display status badge with color coordination
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: goal.statusColor.withOpacity(0.2), // Light background for the badge
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  goal.status.replaceAll('_', ' ').toUpperCase(), // Format status string (e.g., "IN PROGRESS")
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: goal.statusColor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          if (goal.description.isNotEmpty) // Display description if not empty
                            Text(
                              goal.description,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                          if (goal.dueDate != null) // Display due date if available
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 8),
                                  Text(
                                    'Due: ${goal.dueDate!.toLocal().toString().split(' ')[0]}', // Display date part only
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating Action Button to add new goals
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_edit_goal'); // Navigate to the Add/Edit Goal screen to add a new goal
        },
        backgroundColor: Colors.blue.shade600,
        child: Icon(Icons.add, color: Colors.white), // Plus icon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded FAB shape
      ),
    );
  }
}