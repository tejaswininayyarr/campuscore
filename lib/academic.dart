// lib/screens/academic_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'models/academic_resources.dart'; // Make sure this path is correct

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

  // Define some custom colors for consistency
  final Color _primaryBlue = Colors.blue.shade700;
  final Color _accentGreen = Colors.green.shade600;
  final Color _lightGrey = Colors.grey.shade200;
  final Color _darkGrey = Colors.grey.shade700;

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
      backgroundColor: _lightGrey, // A subtle background color
      appBar: AppBar(
        title: Text(
          _selectedCategory == null
              ? 'Academic Resources'
              : _selectedCategory!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryBlue,
        elevation: 4.0, // Add some shadow to the app bar
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios), // A slightly modern back arrow
                onPressed: _resetSelection,
              )
            : null,
      ),
      body: _buildBody(context),
    );
  }

  // Builds the main content of the screen based on the currently selected category.
  Widget _buildBody(BuildContext context) {
    if (_selectedCategory == null) {
      // If no category is selected, show the main list of academic resource types
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _darkGrey,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.count( // Changed to GridView for a more visual layout
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2, // Adjust aspect ratio for card size
                children: [
                  _buildAcademicCategoryTile(
                    context,
                    title: 'Announcements',
                    icon: Icons.campaign_outlined,
                    color: Colors.orange.shade700, // Different color for Announcements
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
                    color: Colors.teal.shade700, // Different color for Syllabus
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
                    color: Colors.purple.shade700, // Different color for Notes
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
                    color: Colors.red.shade700, // Different color for Timetable
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Timetable';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
    required Color color, // Add color parameter
  }) {
    return Card(
      elevation: 6, // Increased elevation for a floating effect
      margin: EdgeInsets.zero, // GridView handles spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
      ),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell( // Use InkWell for ripple effect on tap
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient( // Subtle gradient background
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 48), // White icons on colored background
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the UI for selecting course and semester, and then displaying resources based on selection.
  Widget _buildCourseSemesterAndDownloadableList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Course:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue, width: 2),
                  ),
                  labelText: 'Course',
                  labelStyle: TextStyle(color: _darkGrey),
                  prefixIcon: Icon(Icons.school, color: _primaryBlue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text(
                  'Choose your course',
                  style: TextStyle(color: _darkGrey.withOpacity(0.7)),
                ),
                items: _courses.map((String course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Text(course, style: TextStyle(color: _darkGrey)),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue, width: 2),
                  ),
                  labelText: 'Semester',
                  labelStyle: TextStyle(color: _darkGrey),
                  prefixIcon: Icon(Icons.calendar_today, color: _primaryBlue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text(
                  'Choose your semester',
                  style: TextStyle(color: _darkGrey.withOpacity(0.7)),
                ),
                items: _semesters.map((String semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester, style: TextStyle(color: _darkGrey)),
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
        Expanded(
          child: (_selectedCourse != null && _selectedSemester != null)
              ? _buildDownloadableList(
                  _selectedCategory!,
                  _selectedCourse!,
                  _selectedSemester!,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_up_alt, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 20),
                        Text(
                          'Select your course and semester above to view available $_selectedCategory resources.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // Builds the list of downloadable academic resources (Syllabus, Notes, Timetable)
  Widget _buildDownloadableList(String category, String course, String semester) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('academic_resources')
          .where('category', isEqualTo: category)
          .where('course', isEqualTo: course)
          .where('semester', isEqualTo: semester)
          .orderBy('publishedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _primaryBlue));
        }
        if (snapshot.hasError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                const SizedBox(height: 20),
                Text(
                  'Error loading resources: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red.shade700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please ensure your internet connection is stable and Firestore rules/indexes are correctly set up.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _darkGrey),
                ),
              ],
            ),
          ));
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
                  const SizedBox(height: 10),
                  Text(
                    'Content will appear here once uploaded.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: _darkGrey),
                  ),
                ],
              ),
            ),
          );
        }
        final resources = snapshot.data!.docs.map((doc) => AcademicResource.fromFirestore(doc)).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16.0), // Consistent padding
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Card(
              elevation: 4, // Slightly higher elevation
              margin: const EdgeInsets.only(bottom: 16.0), // More space between cards
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // More rounded corners
              child: InkWell( // Added InkWell for ripple effect on the whole card
                onTap: (resource.fileUrl != null && resource.fileUrl!.isNotEmpty)
                    ? () => _launchURL(resource.fileUrl!)
                    : null,
                borderRadius: BorderRadius.circular(15), // Match card border radius
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Padding inside the card
                  child: Row(
                    children: [
                      Icon(
                        category == 'Syllabus' ? Icons.description
                        : category == 'Notes' ? Icons.sticky_note_2
                        : Icons.calendar_month,
                        color: _primaryBlue,
                        size: 36, // Larger icon
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _darkGrey,
                              ),
                            ),
                            if (resource.description != null && resource.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  resource.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Published: ${DateFormat('MMM d, yyyy').format(resource.publishedDate)} by ${resource.publishedBy ?? 'Admin'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (resource.fileUrl != null && resource.fileUrl!.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.download_for_offline, color: _accentGreen, size: 30), // More prominent download icon
                          onPressed: () => _launchURL(resource.fileUrl!),
                          tooltip: 'Download Resource',
                        ),
                    ],
                  ),
                ),
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
          .collection('announcements')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _primaryBlue));
        }
        if (snapshot.hasError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                const SizedBox(height: 20),
                Text(
                  'Error loading announcements: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red.shade700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please ensure your internet connection is stable and Firestore rules are correctly set up.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _darkGrey),
                ),
              ],
            ),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'No announcements yet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Stay tuned for updates!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: _darkGrey),
                  ),
                ],
              ),
            ),
          );
        }

        final announcements = snapshot.data!.docs.map((doc) => AcademicResource.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      title: Text(
                        announcement.title,
                        style: TextStyle(fontWeight: FontWeight.bold, color: _primaryBlue),
                      ),
                      content: SingleChildScrollView(
                        child: Text(
                          announcement.content ?? 'No content available.',
                          style: TextStyle(color: _darkGrey, fontSize: 16),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close', style: TextStyle(color: _primaryBlue)),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        announcement.content ?? 'No content available.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _darkGrey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${DateFormat('MMM d, yyyy - hh:mm a').format(announcement.publishedDate)} by ${announcement.publishedBy ?? 'Admin'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}