// Placeholder screen for the Student Guidance (Roadmap & Resume) feature. 
import 'package:flutter/material.dart'; 
 
class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('Student Guidance', style: TextStyle(color: 
Colors.white)), 
        backgroundColor: Colors.blue.shade700, 
        elevation: 0, 
        centerTitle: true, 
      ), 
      body: Center( 
        child: Padding( 
          padding: const EdgeInsets.all(24.0), 
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [ 
              Icon(Icons.lightbulb, size: 80, color: 
Colors.blue.shade300), 
              SizedBox(height: 20), 
              Text( 
                'Roadmaps and resume guidance are on their way!', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 22, fontWeight: 
FontWeight.bold, color: Colors.blue.shade800), 
              ), 
              SizedBox(height: 10), 
              Text( 
                'Get step-by-step roadmaps for your academic journey and tools to build a strong resume.', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 16, color: 
Colors.grey.shade600), 
              ), 
            ], 
          ), 
        ), 
      ), 
    ); 
  } 
} 
