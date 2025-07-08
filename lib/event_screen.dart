// lib/screens/campus_events_screen.dart
import 'package:flutter/material.dart';

class CampusEventsScreen extends StatelessWidget {
  const CampusEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center( // Center content within the tab view area
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Stay updated with all the exciting events happening on campus!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 40),
            Text(
              'Event listings coming soon!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}