// Placeholder screen for the Alumni Network feature. 
import 'package:flutter/material.dart'; 
import 'models/alumni_model.dart';
class AlumniScreen extends StatelessWidget { 
  //const AlumniScreen({super.key});

final List<Alumni> demoAlumniData = [
    Alumni(
      name: 'Mr. X. Reddy',
      graduationYear: 2012,
      degreeMajor: 'B.Tech. - Computer Science',
      occupation: 'Software Engineer',
      company: 'Tech Giant',
      location: 'Bangalore',
    ),
    Alumni(
      name: 'Ms. Y. Devi',
      graduationYear: 2017,
      degreeMajor: 'MBA',
      occupation: 'Marketing Director',
      company: 'Global FMCG',
      location: 'Mumbai',
    ),
    Alumni(
      name: 'Dr. Z. Khan',
      graduationYear: 2005,
      degreeMajor: 'Ph.D. - Biotechnology',
      occupation: 'Research Scientist',
      company: 'Pharmaceutical R&D',
      location: 'USA',
    ),
    Alumni(
      name: 'Ms. P. Sharma',
      graduationYear: 2010,
      degreeMajor: 'B.A. - Economics',
      occupation: 'Financial Analyst',
      company: 'Investment Bank',
      contribution: 'Active mentor for current students',
    ),
    Alumni(
      name: 'Mr. Q. Kumar',
      graduationYear: 2018,
      degreeMajor: 'B.Arch. - Architecture',
      occupation: 'Architect',
      company: 'Design Studio',
    ),
    Alumni(
      name: 'Ms. R. Singh',
      graduationYear: 2015,
      degreeMajor: 'M.Sc. - Environmental Science',
      occupation: 'Environmental Consultant',
      company: 'Sustainability Firm',
    ),
  ];

  //const AlumniScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumni Network', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: demoAlumniData.length,
        itemBuilder: (context, index) {
          final alumni = demoAlumniData[index];
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
                    alumni.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Class of: ${alumni.graduationYear} | ${alumni.degreeMajor}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Occupation: ${alumni.occupation} at ${alumni.company}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  if (alumni.location != null && alumni.location!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Location: ${alumni.location}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                  if (alumni.contribution != null && alumni.contribution!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Contribution: ${alumni.contribution}',
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.blue.shade600),
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