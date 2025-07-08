// lib/home_screen.dart

// This is the main screen displayed after a user successfully logs in.
// It provides navigation to various features of the College Connect app.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for User type
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED to fetch username from Firestore
import 'auth_service.dart'; // Import the AuthService for logout functionality

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _username = 'Loading...';
  User? _currentUser;
  int _selectedIndex = 0; // Keep track of selected tab for home view

  // Flag to ensure the SnackBar is shown only once when the screen is first loaded
  bool _profileUpdateHandled = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUsername(); // Initiate fetching the username from Firestore
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_profileUpdateHandled) {
      _showProfileUpdateSuccess();
    }
  }

  void _showProfileUpdateSuccess() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map && args['profileUpdated'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      _profileUpdateHandled = true;
    }
  }

  Future<void> _fetchUsername() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc.get('name') ?? 'User';
          });
        } else {
          setState(() {
            _username = _currentUser!.email ?? 'Guest';
          });
        }
      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          _username = _currentUser!.email ?? 'Guest';
        });
      }
    } else {
      setState(() {
        _username = 'Guest';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _homeContentView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.waving_hand, size: 40, color: Colors.orange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Hello, $_username!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // You can add other introductory content or a message here if desired
            Center(
              child: Text(
                'Welcome to College Connect!',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on selected index
    switch (index) {
      case 0:
        // Already on home, no explicit navigation needed, but ensure it's the top
        // Navigator.popUntil(context, ModalRoute.withName('/home')); // Use if home needs to be root
        break;
      case 1:
        Navigator.of(context).pushNamed('/academic_resources');
        break;
      case 2:
        Navigator.of(context).pushNamed('/campus_events');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Connect', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                _username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                _currentUser?.email ?? 'No Email',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _onItemTapped(0); // Select Home tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Goals & Tasks'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/goals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Mentorship'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/mentorship');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt),
              title: const Text('Alumni'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/alumni');
                _showSnackBar(context, 'Alumni Network feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_pin),
              title: const Text('Faculty'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/faculty');
                _showSnackBar(context, 'Faculty Information feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Student Guidance'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/guidance');
                _showSnackBar(context, 'Student Guidance feature coming soon!');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer first
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: _homeContentView(), // Home screen only shows the welcome message
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        onTap: _onItemTapped,
      ),
    );
  }
}