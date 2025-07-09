// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the generated Firebase options file. This file is created by `flutterfire configure`.
import 'firebase_options.dart';

// Import custom services and screens
import 'auth_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'user_profile_screen.dart';
import 'goal_task_manager_screen.dart';
import 'add_edit_goal_screen.dart';
import 'goal_model.dart';
// import 'mentorship_screen.dart'; // REMOVED: Mentorship screen import
import 'alumni_screen.dart';
import 'faculty_screen.dart';
import 'guidance_screen.dart';
import 'academic.dart';
import 'event_screen.dart';
import 'add_event_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: EdgeInsets.all(8),
        ),
        appBarTheme: AppBarTheme( // Added for consistent AppBar styling
          color: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/goals': (context) => GoalTaskManagerScreen(),
        '/add_edit_goal': (context) {
          final Goal? goal = ModalRoute.of(context)?.settings.arguments as Goal?;
          return AddEditGoalScreen(goal: goal);
        },
        // '/mentorship': (context) => MentorshipScreen(), // REMOVED: Mentorship screen route
        '/alumni': (context) => AlumniScreen(),
        '/faculty': (context) => FacultyScreen(),
        '/guidance': (context) => GuidanceScreen(),
        '/add_event': (context) => AddEventScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('AuthWrapper building...');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('StreamBuilder connectionState: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: ConnectionState.waiting - Showing CircularProgressIndicator');
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          print('AuthWrapper: Stream has error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          print('AuthWrapper: User is logged in (${snapshot.data?.email}) - Navigating to HomeScreen');
          return HomeScreen();
        } else {
          print('AuthWrapper: User is NOT logged in - Navigating to LoginScreen');
          return LoginScreen();
        }
      },
    );
  }
}