// Placeholder screen for the Faculty Information feature. 
import 'package:flutter/material.dart'; 
 
class FacultyScreen extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('Faculty Information', style: TextStyle(color: Colors.white)), 
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
              Icon(Icons.person_pin, size: 80, color: Colors.blue.shade300), 
              SizedBox(height: 20), 
              Text( 
                'Faculty profiles will be available soon!', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 22, fontWeight:FontWeight.bold, color: Colors.blue.shade800), 
              ), 
              SizedBox(height: 10), 
              Text( 
                'Find information about your professors, their research, and office hours.', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600), 
              ), 
            ], 
          ), 
        ), 
      ), 
    ); 
  } 
} 