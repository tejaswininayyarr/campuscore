//lib/screens/campus_events_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart'; // Keep this import
import 'models/event.dart';
import 'package:intl/intl.dart';

class CampusEventsScreen extends StatelessWidget {
  const CampusEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                direction: FlipDirection.HORIZONTAL,
                // By default, flipOnTap is true, meaning tapping anywhere on the card will flip it.
                // We remove the InkWell from the back side to prevent navigation on flip.
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  DateFormat('MMM d,yyyy - h:mm a').format(event.date),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modified back of the card to include a 'View Details' button
  Widget _buildEventCardBack(BuildContext context, Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding( // Removed InkWell from here so card flips on tap anywhere, not just for navigation
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Date: ${DateFormat('MMM d,yyyy').format(event.date)}',
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
              child: ElevatedButton.icon( // Added a dedicated button for details
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/event_detail',
                    arguments: event,
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}