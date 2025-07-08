// lib/mentorship_screen.dart
import 'package:flutter/material.dart';
// import 'package:college_connect/models/mentor.dart'; // Keep this import for future use

class MentorshipScreen extends StatefulWidget {
  const MentorshipScreen({super.key});

  @override
  State<MentorshipScreen> createState() => _MentorshipScreenState();
}

class _MentorshipScreenState extends State<MentorshipScreen> {
  // Controllers for search bar and selected filter/sort options
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMajor;
  String? _selectedBatch;
  String? _selectedSkill;
  String? _selectedIndustry;
  String? _selectedAvailability;
  String? _selectedSortOption;

  // Placeholder lists for dropdown options (these would typically come from a database)
  final List<String> _majors = ['All', 'Computer Science', 'Electrical Engineering', 'Business Administration', 'Mechanical Engineering', 'Biotechnology'];
  final List<String> _batches = ['All', '2010', '2005', '2015', '2012', '2008'];
  final List<String> _skills = ['All', 'Software Development', 'AI/ML', 'Robotics', 'Marketing', 'Entrepreneurship', 'Product Design', 'Genetics'];
  final List<String> _industries = ['All', 'Tech', 'Automotive', 'Healthcare', 'Finance', 'Education'];
  final List<String> _availability = ['All', 'Available Now', 'Flexible', 'Weekends'];
  final List<String> _sortOptions = ['Relevance', 'Availability', 'Newest', 'Name (A-Z)'];

  // This list will hold the filtered/sorted mentors, initially empty
  List<dynamic> _mentors = []; // Using dynamic for now, will be List<Mentor> later

  @override
  void initState() {
    super.initState();
    // Initialize default filter/sort options if needed
    _selectedMajor = _majors.first;
    _selectedBatch = _batches.first;
    _selectedSkill = _skills.first;
    _selectedIndustry = _industries.first;
    _selectedAvailability = _availability.first;
    _selectedSortOption = _sortOptions.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Helper Widget for Dropdowns (reusable) ---
  Widget _buildFilterDropdown({
    required String hintText,
    required String? selectedValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(hintText, style: TextStyle(color: Colors.grey.shade700)),
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
          isDense: true,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          dropdownColor: Colors.white, // Background color of dropdown menu
          style: const TextStyle(color: Colors.black87), // Default text style for items
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Mentor', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search mentors by name...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {}); // Rebuild to clear icon
                            // TODO: Trigger mentor list update here
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear icon
                  // TODO: Implement live search filtering here
                },
              ),
            ),
            // --- Filter & Sort Options Section ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Allows horizontal scrolling for filters
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterDropdown(
                    hintText: 'Major',
                    selectedValue: _selectedMajor,
                    items: _majors,
                    onChanged: (value) {
                      setState(() { _selectedMajor = value; });
                      // TODO: Apply filter
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildFilterDropdown(
                    hintText: 'Batch',
                    selectedValue: _selectedBatch,
                    items: _batches,
                    onChanged: (value) {
                      setState(() { _selectedBatch = value; });
                      // TODO: Apply filter
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildFilterDropdown(
                    hintText: 'Skill',
                    selectedValue: _selectedSkill,
                    items: _skills,
                    onChanged: (value) {
                      setState(() { _selectedSkill = value; });
                      // TODO: Apply filter
                    },
                  ),
                  const SizedBox(width: 10),
                   _buildFilterDropdown(
                    hintText: 'Industry',
                    selectedValue: _selectedIndustry,
                    items: _industries,
                    onChanged: (value) {
                      setState(() { _selectedIndustry = value; });
                      // TODO: Apply filter
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildFilterDropdown(
                    hintText: 'Availability',
                    selectedValue: _selectedAvailability,
                    items: _availability,
                    onChanged: (value) {
                      setState(() { _selectedAvailability = value; });
                      // TODO: Apply filter
                    },
                  ),
                  const SizedBox(width: 20), // Separator for Sort
                  _buildFilterDropdown( // Reusing for Sort
                    hintText: 'Sort By',
                    selectedValue: _selectedSortOption,
                    items: _sortOptions,
                    onChanged: (value) {
                      setState(() { _selectedSortOption = value; });
                      // TODO: Apply sorting
                    },
                  ),
                ],
              ),
            ),
            // --- Mentor List Display Area ---
            Expanded(
              child: _mentors.isEmpty // This list is currently empty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 70, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(height: 20),
                          Text(
                            'No mentors found. Try adjusting your search or filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Mentors will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      // This part will display mentor cards once data is fetched/filtered
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _mentors.length,
                      itemBuilder: (context, index) {
                        // TODO: Replace with MentorCard(mentor: _mentors[index]) when data is ready
                        return const Text('Mentor Item Placeholder', style: TextStyle(color: Colors.white));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}