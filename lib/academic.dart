// lib/screens/academic_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Make sure you have intl: ^0.18.1 (or latest) in your pubspec.yaml
import 'models/academic_resources.dart'; // Corrected import path

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});
  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}
class _AcademicScreenState extends State<AcademicScreen> {
  String? _selectedCategory;
  String? _selectedCourse;
  String? _selectedSemester;

  // Predefined lists for courses and semesters
  final List<String> _courses = ['BCA', 'BBA', 'BA(Eco)'];
  final List<String> _semesters = [
    '1st Semester', '2nd Semester', '3rd Semester', '4th Semester',
    '5th Semester', '6th Semester', 
  ]; 
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching URL: $e')),
        );
      }
    }
  }
  void _resetSelection() {
    setState(() {
      _selectedCategory = null;
      _selectedCourse = null;
      _selectedSemester = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCategory == null
              ? 'Academic Resources'
              : _selectedCategory!, // Display selected category or main title
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _resetSelection, // Go back to the main category list
              )
            : null, // No back button on the initial main category list
      ),
      body: _buildBody(context), // Delegates to a method that builds content based on selected category
    );
  }
  // Builds the main content of the screen based on the currently selected category.
  Widget _buildBody(BuildContext context) {
    if (_selectedCategory == null) {
      // If no category is selected, show the main list of academic resource types
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAcademicCategoryTile(
            context,
            title: 'Academic Announcements',
            icon: Icons.campaign,
            onTap: () {
              setState(() {
                _selectedCategory = 'Announcements';
              });
            },
          ),
          _buildAcademicCategoryTile(
            context,
            title: 'Syllabus',
            icon: Icons.assignment_outlined,
            onTap: () {
              setState(() {
                _selectedCategory = 'Syllabus';
              });
            },
          ),
          _buildAcademicCategoryTile(
            context,
            title: 'Notes',
            icon: Icons.notes,
            onTap: () {
              setState(() {
                _selectedCategory = 'Notes';
              });
            },
          ),
          _buildAcademicCategoryTile(
            context,
            title: 'Time Table',
            icon: Icons.schedule,
            onTap: () {
              setState(() {
                _selectedCategory = 'Timetable';
              });
            },
          ),
        ],
      );
    } else if (_selectedCategory == 'Announcements') {
      // If 'Announcements' is selected, show the announcements list directly
      return _buildAnnouncementsList();
    } else {
      // For 'Syllabus', 'Notes', 'Timetable', show course/semester selection, then the downloadable list
      return _buildCourseSemesterAndDownloadableList();
    }
  }
  /// Helper widget to create a tile for academic categories.
  Widget _buildAcademicCategoryTile(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
  // Builds the UI for selecting course and semester, and then displaying resources based on selection.
  Widget _buildCourseSemesterAndDownloadableList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Course:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Course',
                  prefixIcon: Icon(Icons.school),
                ),
                hint: const Text('Choose your course'),
                items: _courses.map((String course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Text(course),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                    _selectedSemester = null; // Reset semester when course changes
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Select Semester:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Semester',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                hint: const Text('Choose your semester'),
                items: _semesters.map((String semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSemester = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        // Only show the list if both course and semester are selected
        Expanded(
          child: (_selectedCourse != null && _selectedSemester != null)
              ? _buildDownloadableList(
                  _selectedCategory!, // Guaranteed not null here by the _buildBody logic
                  _selectedCourse!,   // Guaranteed not null here by the above check
                  _selectedSemester!, // Guaranteed not null here by the above check
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'Please select a course and semester to view $_selectedCategory.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
  // Builds the list of downloadable academic resources (Syllabus, Notes, Timetable)
  /// filtered by category, course, and semester.
  Widget _buildDownloadableList(String category, String course, String semester) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('academic_resources') // Collection for resources
          .where('category', isEqualTo: category)
          .where('course', isEqualTo: course)
          .where('semester', isEqualTo: semester)
          .orderBy('publishedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading resources: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'No $category available for $course ($semester) yet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }
        final resources = snapshot.data!.docs.map((doc) => AcademicResource.fromFirestore(doc)).toList();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(
                  // Choose icon based on category
                  category == 'Syllabus' ? Icons.description
                  : category == 'Notes' ? Icons.sticky_note_2
                  : Icons.calendar_month, // Default for Timetable
                  color: Colors.blue.shade700,
                  size: 30,
                ),
                title: Text(
                  resource.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: resource.description != null && resource.description!.isNotEmpty
                    ? Text(
                        resource.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    : null, // Don't show subtitle if description is empty
                trailing: (resource.fileUrl != null && resource.fileUrl!.isNotEmpty)
                    ? IconButton(
                        icon: const Icon(Icons.download, color: Colors.green),
                        onPressed: () => _launchURL(resource.fileUrl!),
                      )
                    : null, // Don't show download icon if no file URL
                onTap: (resource.fileUrl != null && resource.fileUrl!.isNotEmpty)
                    ? () => _launchURL(resource.fileUrl!) // Open URL on tile tap
                    : null, // Disable tap if no file URL
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the list of academic announcements.
  Widget _buildAnnouncementsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements') // Collection for announcements
          .orderBy('date', descending: true) // Assuming 'date' field for announcements
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading announcements: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FIX: Changed Icons.campaign_off to Icons.notifications_off
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'No announcements yet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        final announcements = snapshot.data!.docs.map((doc) => AcademicResource.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  announcement.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.content ?? 'No content available.', // Display content, with fallback
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Format date and display publisher
                      '${DateFormat('MMM d,yyyy').format(announcement.publishedDate)} by ${announcement.publishedBy ?? 'Admin'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                onTap: () {
                  // Show full announcement in a dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(announcement.title),
                      content: SingleChildScrollView(
                        child: Text(announcement.content ?? 'No content available.'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}