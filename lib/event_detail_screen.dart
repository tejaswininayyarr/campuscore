import 'package:flutter/material.dart';
import 'models/event.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  // Method to show confirmation dialog and delete event
  Future<void> _confirmAndDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.title}"? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Dismiss and return false
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // Dismiss and return true
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // User confirmed deletion
      try {
        await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully!')),
        );
        // After deletion, pop back to the previous screen (CampusEventsScreen)
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmAndDelete(context), // Call the delete method
            tooltip: 'Delete Event',
          ),
          // You could also add an edit button here if you want to reuse AddEventScreen for editing
          // IconButton(
          //   icon: const Icon(Icons.edit),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/add_event', arguments: event);
          //   },
          //   tooltip: 'Edit Event',
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_today, DateFormat('EEEE, MMM d,yyyy').format(event.date)),
            _buildInfoRow(Icons.access_time, event.time),
            _buildInfoRow(Icons.location_on, event.location),
            _buildInfoRow(Icons.person, 'Organizer: ${event.organizer}'),
            _buildInfoRow(Icons.contact_mail, 'Contact: ${event.contactInfo}'),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}