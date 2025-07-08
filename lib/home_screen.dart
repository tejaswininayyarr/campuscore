// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart'; // Make sure this path is correct

// Import the content widgets for your bottom nav tabs.
// These screens (AcademicResourcesScreen, CampusEventsScreen) should NOT have their own Scaffold or AppBar.
import 'academic.dart'; // Ensure path is correct
import 'event_screen.dart'; 
import 'add_event_screen.dart';    // Ensure path is correct

// Import other screens accessible via the Drawer (these will still be full Scaffolds)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _username = 'Loading...';
  User? _currentUser;
  int _selectedIndex = 0; // Tracks the currently selected tab for the BottomNavigationBar

  // List of widgets corresponding to each tab in the BottomNavigationBar.
  // The first widget is the content for the "Home" tab.
  late final List<Widget> _widgetOptions;

  // Titles for the AppBar that will change based on the selected tab.
  final List<String> _appBarTitles = const [
    'College Connect',      // Title for 'Home' tab
    'Academic Resources',   // Title for 'Academic' tab
    'Campus Events',        // Title for 'Event' tab
  ];

  // Flag to ensure the profile update SnackBar is shown only once per screen load.
  bool _profileUpdateHandled = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUsername(); // Initiate fetching username from Firestore

    // Initialize the list of widgets for our IndexedStack.
    // The first item is the actual content for the "Home" tab.
    _widgetOptions = <Widget>[
      // Content for the "Home" tab directly embedded here
      SingleChildScrollView(
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
                          // Using a placeholder username initially, will be updated when fetched.
                          'Hello, $_username!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Welcome to College Connect!',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Add any other specific content for the Home tab here
            ],
          ),
        ),
      ),
      const AcademicScreen(), // Content for the "Academic" tab (from its separate file)
      const CampusEventsScreen(),       // Content for the "Event" tab (from its separate file)
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for profile update arguments only once when the dependencies change.
    if (!_profileUpdateHandled) {
      _showProfileUpdateSuccess();
    }
  }

  // Displays a SnackBar if a profile update was successful (from a previous screen).
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
      _profileUpdateHandled = true; // Set flag to true to prevent re-showing.
    }
  }

  // Fetches the username from Firestore based on the current user's UID.
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
            // Update the Home content widget in _widgetOptions with the fetched username.
            _widgetOptions[0] = SingleChildScrollView(
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
                    const Center(
                      child: Text(
                        'Welcome to College Connect!',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          });
        } else {
          // Fallback if user document doesn't exist
          setState(() {
            _username = _currentUser!.email ?? 'Guest';
            _widgetOptions[0] = SingleChildScrollView(
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
                    const Center(
                      child: Text(
                        'Welcome to College Connect!',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          });
        }
      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          _username = _currentUser!.email ?? 'Guest';
          _widgetOptions[0] = SingleChildScrollView(
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
                  const Center(
                    child: Text(
                      'Welcome to College Connect!',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      }
    } else {
      setState(() {
        _username = 'Guest';
        _widgetOptions[0] = SingleChildScrollView(
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
                const Center(
                  child: Text(
                    'Welcome to College Connect!',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      });
    }
  }

  // Handles taps on the BottomNavigationBar items.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Updates the selected index, triggering IndexedStack to show new content.
    });
    // No Navigator.pushNamed here, as we are just switching content within this same Scaffold.
  }

  // Helper method to show a SnackBar message.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex], // App bar title changes with the selected tab
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
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
                _username, // Displays the fetched username
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
                _onItemTapped(0); // Manually set to Home tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/profile'); // Navigates to a separate screen
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
      // This is the core for persistent content switching.
      // IndexedStack only shows one child at a time based on _selectedIndex.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Academic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event',
          ),
        ],
        currentIndex: _selectedIndex, // Highlights the currently selected tab
        selectedItemColor: Colors.blue.shade700,
        onTap: _onItemTapped, // Calls our method to update _selectedIndex
      ),
            // NEW: Floating Action Button
      floatingActionButton: _selectedIndex == 2 // Show FAB only on the 'Event' tab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_event'); // Navigate to AddEventScreen
              },
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null, // Don't show FAB on other tabs
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}