// This file defines the data model for a Goal or Task. 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; // Required for Color and IconData 
 
class Goal { 
  String? id; // The document ID from Firestore. Optional, as it's assigned after creation. 
  final String userId; // The ID of the user who owns this goal. 
  String title; // The title of the goal/task. 
  String description; // A detailed description of the goal/task. 
  DateTime? dueDate; // Optional due date for the goal. 
  String status; // The current status of the goal (e.g., 'pending', 'in_progress', 'completed', 'overdue'). 
 
  // Constructor for the Goal class. 
  Goal({ 
    this.id, 
    required this.userId, 
    required this.title, 
    this.description = '', // Default empty description 
    this.dueDate, 
    this.status = 'pending', // Default status is 'pending' 
  }); 
 
  // Factory constructor to create a Goal object from a Firestore DocumentSnapshot. 
  // This is used when reading data from Firestore. 
  factory Goal.fromFirestore(DocumentSnapshot doc) { 
    Map data = doc.data() as Map<String, dynamic>; // Cast the data to a Map 
    return Goal( 
      id: doc.id, // Assign the Firestore document ID to the Goal object's id property 
      userId: data['userId'] ?? '', // Get userId, default to empty string if null 
      title: data['title'] ?? 'No Title', // Get title, default if null 
      description: data['description'] ?? '', // Get description, default if null 
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(), // Convert Firestore Timestamp to Dart DateTime 
      status: data['status'] ?? 'pending', // Get status, default if null 
    ); 
  } 
 
  // Converts a Goal object into a Map suitable for writing to Firestore. 
  // This is used when creating or updating data in Firestore. 
  Map<String, dynamic> toFirestore() { 
    return { 
      'userId': userId, 
      'title': title, 
      'description': description, 
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null, // Convert Dart DateTime to Firestore Timestamp 
      'status': status, 
      'createdAt': FieldValue.serverTimestamp(), // Automatically sets creation time using Firestore server timestamp 
      'updatedAt': FieldValue.serverTimestamp(), // Automatically updates this field on every save 
    }; 
  } 
 
  // Getter to return a Color based on the goal's status for visual indication. 
  Color get statusColor { 
    switch (status) { 
      case 'completed': 
        return Colors.green.shade600; // Green for completed goals 
      case 'in_progress': 
        return Colors.blue.shade600; // Blue for goals in progress 
      case 'overdue': 
        return Colors.red.shade600; // Red for overdue goals 
      case 'pending': 
      default: 
        return Colors.orange.shade600; // Orange for pending goals 
    } 
  } 
 
  // Getter to return an IconData based on the goal's status for visual indication. 
  IconData get statusIcon { 
    switch (status) { 
      case 'completed': 
        return Icons.check_circle; // Checkmark for completed 
      case 'in_progress': 
        return Icons.hourglass_bottom; // Hourglass for in progress 
      case 'overdue': 
        return Icons.error; // Error icon for overdue 
      case 'pending': 
      default: 
        return Icons.pending_actions; // Pending icon for pending 
    } 
  } 
} 