// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import '
// Import the generated Firebase options file. This file is created by
// `flutterfire configure`.
// If you see an error here, re-run `flutterfire configure` in your
// project root.
import 'firebase_options.dart';

// Import custom services and screens
import 'event_screen.dart';
import 'academic.dart';
import 'auth_service.dart'; // Ensure this path is correct based on your project name
import 'login_screen.dart'; // Ensure this path is correct
import 'signup_screen.dart'; // Ensure this path is correct
import 'home_screen.dart';
import 'user_profile_screen.dart';
import 'goal_task_manager_screen.dart';
import 'add_edit_goal_screen.dart';
import 'goal_model.dart'; // <--- IMPORTANT: Ensure this is imported for Goal type recognition
import 'mentorship_screen.dart'; // Placeholder screen
import 'alumni_screen.dart'; // Placeholder screen
import 'faculty_screen.dart'; // Placeholder screen
import 'guidance_screen.dart'; // Placeholder screen


void main() async {
  // Ensure Flutter widgets are initialized before Firebase. This is crucial.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options for the current platform.
  // This must be called before using any Firebase services.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!'); // For debugging, consider removing in prod
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Consider showing an error dialog or handling this more gracefully in a real app.
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define your routes
      initialRoute: '/', // Or '/login' if you want login to be the first screen
      routes: {
        // Updated to use the correct class names directly without 'new' or 'const' if not needed
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return HomeScreen(); // User is logged in
                }
                return LoginScreen(); // User is not logged in, show login
              },
            ),
        '/login': (context) => LoginScreen(), // Correctly referencing LoginScreen
        '/signup': (context) => SignupScreen(), // Correctly referencing SignupScreen
        '/home': (context) =>  HomeScreen(),
        '/profile': (context) =>  UserProfileScreen(),
        '/goals': (context) =>  GoalTaskManagerScreen(),
        '/add_goal': (context) =>  AddEditGoalScreen(),
        '/mentorship': (context) =>  MentorshipScreen(),
        '/alumni': (context) =>  AlumniScreen(),
        '/faculty': (context) => FacultyScreen(),
        '/guidance': (context) => GuidanceScreen(),
        '/academic_resources': (context) =>  AcademicResourcesScreen(),
        '/campus_events': (context) =>  CampusEventsScreen(),
      },
      // You can also define an onGenerateRoute for more dynamic routing,
      // especially for passing arguments to screens like AddEditGoalScreen
      onGenerateRoute: (settings) {
        if (settings.name == '/edit_goal') {
          final Goal? goal = settings.arguments as Goal?;
          return MaterialPageRoute(
            builder: (context) {
              return AddEditGoalScreen(goal: goal);
            },
          );
        }
        return null; // Let the app handle other unknown routes
      },
    );
  }
}