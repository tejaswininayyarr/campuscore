import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart'; // Import the flip_card package
import '/models/event.dart'; // Import your Event model
import 'event_detail_screen.dart'; // Import the detail screen
import 'package:intl/intl.dart'; // For date formatting

class CampusEventsScreen extends StatelessWidget {
  const CampusEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen does not have its own Scaffold or AppBar,
    // as it's part of the HomeScreen's IndexedStack.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('date', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No upcoming events yet!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL, // default
                front: _buildEventCardFront(event),
                back: _buildEventCardBack(context, event), // Pass context to navigate
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventCardFront(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Clip children to the rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Event Poster Image
          Image.network(
            event.imageUrl,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                ),
              );
            },
          ),
          // Event Title and Date
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy - h:mm a').format(event.date.add(Duration(hours: int.parse(event.time.split(':')[0]), minutes: int.parse(event.time.split(':')[1].split(' ')[0])))), // Basic time parsing
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCardBack(BuildContext context, Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: InkWell( // Use InkWell for tap effect on the back
        onTap: () {
          // Navigate to the detail screen when the back of the card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Date: ${DateFormat('MMM d, yyyy').format(event.date)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'Time: ${event.time}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'Location: ${event.location}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  'Tap for more details!',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}