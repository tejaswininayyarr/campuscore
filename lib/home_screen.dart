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
    'JIMS - College Connect',      // Title for 'Home' tab
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
      _buildHomeContent(),
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

  // Build the home content widget
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Welcome Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
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
          ),
          
          // College Header Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[800]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JIMS College',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rohini, New Delhi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // College Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About JIMS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'JIMS (Jagan Institute of Management Studies) is a premier educational institution located in Rohini, New Delhi. We offer quality education in Business Administration, Computer Applications, and Economics.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Contact Info
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('📞 +91-7827938610'),
                      SizedBox(height: 4),
                      Text('📧 info@jimsindia.org'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Programs Section
                const Text(
                  'Programs Offered',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Program Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Undergraduate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('• BBA\n• BCA\n• B.A.(Hons.) Economics'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Postgraduate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('• MCA'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Clubs Section
                const Text(
                  'Our Clubs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover our vibrant club activities. Tap on any card to learn more!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Clubs Carousel
          const ClubCarousel(),
          
          const SizedBox(height: 30),
        ],
      ),
    );
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
            _widgetOptions[0] = _buildHomeContent();
          });
        } else {
          // Fallback if user document doesn't exist
          setState(() {
            _username = _currentUser!.email ?? 'Guest';
            _widgetOptions[0] = _buildHomeContent();
          });
        }
      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          _username = _currentUser!.email ?? 'Guest';
          _widgetOptions[0] = _buildHomeContent();
        });
      }
    } else {
      setState(() {
        _username = 'Guest';
        _widgetOptions[0] = _buildHomeContent();
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
// Updated Club Carousel Widget with fixes
class ClubCarousel extends StatefulWidget {
  const ClubCarousel({super.key});

  @override
  State<ClubCarousel> createState() => _ClubCarouselState();
}

class _ClubCarouselState extends State<ClubCarousel> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  
  final List<Map<String, String>> clubs = [
    {
      'name': 'Economics Club',
      'description': 'Exploring economic theories and market trends',
      'activities': '• Debates & Research\n• Market Analysis\n• Guest Lectures\n• Case Studies\n• Policy Discussions',
      'color': '2196F3',
    },
    {
      'name': 'Tekqbe Club',
      'description': 'Technology and innovation focused club',
      'activities': '• Coding Workshops\n• Tech Talks\n• Innovation Projects\n• Hackathons\n• App Development',
      'color': '4CAF50',
    },
    {
      'name': 'Gender Championship Club',
      'description': 'Promoting gender equality and awareness',
      'activities': '• Awareness Campaigns\n• Workshops\n• Panel Discussions\n• Equality Events\n• Research Projects',
      'color': 'FF9800',
    },
    {
      'name': 'Sports Club',
      'description': 'Physical fitness and sports activities',
      'activities': '• Cricket & Football\n• Basketball\n• Athletics\n• Tournaments\n• Fitness Training',
      'color': 'F44336',
    },
    {
      'name': 'Patriotic Club',
      'description': 'Celebrating national spirit and heritage',
      'activities': '• Flag Ceremonies\n• Cultural Events\n• Patriotic Songs\n• Heritage Walks\n• National Celebrations',
      'color': 'FF5722',
    },
    {
      'name': 'Cultural Club',
      'description': 'Arts, music, dance and cultural activities',
      'activities': '• Dance Performances\n• Music Concerts\n• Drama & Theatre\n• Art Exhibitions\n• Cultural Festivals',
      'color': '9C27B0',
    },
  ];

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 300, // Increased height to prevent overflow
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: FlipCard(
                  club: clubs[index],
                  primaryColor: _getColorFromHex(clubs[index]['color']!),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            clubs.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentIndex == index 
                    ? Colors.blue.shade700 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: currentIndex > 0 ? () {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } : null,
              icon: Icon(
                Icons.arrow_back_ios,
                color: currentIndex > 0 ? Colors.blue.shade700 : Colors.grey,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '${currentIndex + 1} of ${clubs.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: currentIndex < clubs.length - 1 ? () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: currentIndex < clubs.length - 1 ? Colors.blue.shade700 : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Improved Flip Card Widget
class FlipCard extends StatefulWidget {
  final Map<String, String> club;
  final Color primaryColor;
  
  const FlipCard({
    super.key, 
    required this.club,
    required this.primaryColor,
  });
  
  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  bool isFlipped = false;
  
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  
  void flipCard() {
    if (!isFlipped) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final isShowingFront = animation.value < 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value * 3.14159),
            child: Container(
              width: double.infinity,
              height: 270, // Slightly reduced to prevent overflow
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isShowingFront ? _buildFrontCard() : _buildBackCard(),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor,
            widget.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                
                // Club Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    _getClubIcon(widget.club['name']!),
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Club Name
                Text(
                  widget.club['name']!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  widget.club['description']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Tap hint
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tap to learn more',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getClubIcon(widget.club['name']!),
                      size: 20,
                      color: widget.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.club['name']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Activities Header
              Text(
                'Activities:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Activities List
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.club['activities']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Back hint
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Tap to go back',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getClubIcon(String clubName) {
    switch (clubName.toLowerCase()) {
      case 'economics club':
        return Icons.trending_up;
      case 'tekqbe club':
        return Icons.computer;
      case 'gender championship club':
        return Icons.people;
      case 'sports club':
        return Icons.sports_football;
      case 'patriotic club':
        return Icons.flag;
      case 'cultural club':
        return Icons.theater_comedy;
      default:
        return Icons.group;
    }
  }
}


