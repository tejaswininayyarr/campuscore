// lib/screens/academic_resources_screen.dart
import 'package:flutter/material.dart';

class AcademicResourcesScreen extends StatelessWidget {
  const AcademicResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center( // Center content within the tab view area
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Access a wealth of academic materials, study guides, and research tools here!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 40),
            Text(
              'More content coming soon!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}