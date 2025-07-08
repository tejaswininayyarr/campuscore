// Placeholder screen for the Alumni Network feature. 
import 'package:flutter/material.dart'; 
 
class AlumniScreen extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('Alumni Network', style: TextStyle(color: Colors.white)), 
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
              Icon(Icons.people_alt, size: 80, color: Colors.blue.shade300), 
              SizedBox(height: 20), 
              Text( 
                'Alumni Network is under development!', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800), 
              ), 
              SizedBox(height: 10), 
              Text( 
                'Connect with college alumni, explore career paths, and expand your professional network.', 
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