// Placeholder screen for the Faculty Information feature. 
import 'package:flutter/material.dart'; 
import 'models/faculty_model.dart'; 
class FacultyScreen extends StatelessWidget { 
  //const FacultyScreen({super.key});

  final List<Faculty> demoFacultyData = [
    Faculty(
      name: 'Dr. A. Sharma',
      department: 'Computer Science',
      role: 'Professor',
      yearsAtUniversity: '15+ years',
    ),
    Faculty(
      name: 'Prof. B. Singh',
      department: 'Liberal Arts',
      role: 'Associate Professor',
      yearsAtUniversity: '8 years',
    ),
    Faculty(
      name: 'Ms. C. Patel',
      department: 'Business School',
      role: 'Lecturer',
      yearsAtUniversity: '3 years',
    ),
    Faculty(
      name: 'Dr. D. Gupta',
      department: 'Electrical Engineering',
      role: 'Department Head',
      yearsAtUniversity: '20+ years',
    ),
    Faculty(
      name: 'Prof. E. Kumar',
      department: 'Physics',
      role: 'Assistant Professor',
      yearsAtUniversity: '5 years',
    ),
    Faculty(
      name: 'Dr. F. Rao',
      department: 'Biotechnology',
      role: 'Professor',
      yearsAtUniversity: '12 years',
    ),
  ];

  const FacultyScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Information', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: demoFacultyData.length,
        itemBuilder: (context, index) {
          final faculty = demoFacultyData[index];
          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faculty.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Department: ${faculty.department}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Role: ${faculty.role}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  if (faculty.yearsAtUniversity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Years at University: ${faculty.yearsAtUniversity}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}