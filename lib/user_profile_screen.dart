// lib/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'dart:io'; // Required for File class
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  User? _currentUser;
  bool _isLoading = true;
  File? _pickedImage; // To hold the image file picked from the device temporarily
  String? _profileImageUrl; // To hold the URL of the profile image from Firestore/Storage

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _emailController.text = _currentUser!.email ?? 'No Email Set';

      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          _nameController.text = userData['name'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          _majorController.text = userData['major'] ?? '';
          _batchController.text = userData['batch'] ?? '';
          _profileImageUrl = userData['profileImageUrl']; // Load existing image URL
        }
      } catch (e) {
        print('Error loading user profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: $e')),
          );
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Method to show a bottom sheet for image source selection (gallery or camera)
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImageSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImageSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick an image from the chosen source
  Future<void> _pickImageSource(ImageSource source) async {
    // imageQuality: 80 compresses the image to 80% quality, reducing file size
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path); // Store the picked file
      });
    }
  }

  // Method to upload the picked image to Firebase Storage
  Future<String?> _uploadProfileImage() async {
    if (_pickedImage == null || _currentUser == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures') // Top-level folder for profile pictures
        .child(_currentUser!.uid) // Subfolder for the current user's UID
        .child('${_currentUser!.uid}_profile.jpg'); // Filename (e.g., userUID_profile.jpg)

    try {
      UploadTask uploadTask = storageRef.putFile(_pickedImage!);
      TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL(); // Get the public URL of the uploaded image
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: ${e.message}')),
        );
      }
      return null;
    } catch (e) {
      print('General Image Upload Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.validate() && _currentUser != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? newImageUrl = _profileImageUrl; // Start with the existing image URL

        // If a new image was picked, upload it first
        if (_pickedImage != null) {
          newImageUrl = await _uploadProfileImage();
          if (newImageUrl == null) {
            // If image upload failed, stop the profile update process
            setState(() {
              _isLoading = false;
            });
            return; // Exit early if image upload failed
          }
        }

        // Update Firebase Auth profile display name (if needed)
        await _currentUser!.updateDisplayName(_nameController.text);

        // Update Firestore document with all profile details and the new (or existing) image URL
        await _firestore.collection('users').doc(_currentUser!.uid).set(
          {
            'name': _nameController.text,
            'email': _currentUser!.email,
            'bio': _bioController.text,
            'major': _majorController.text,
            'batch': _batchController.text,
            'profileImageUrl': newImageUrl, // Save the new or existing image URL
            'lastUpdated': FieldValue.serverTimestamp(), // Timestamp of the last update
          },
          SetOptions(merge: true), // Use merge: true to only update specified fields
        );

        // --- Profile updated successfully ---
        // Removed the SnackBar from THIS screen.
        // Navigating back to the home screen and passing a flag for the message.
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'profileUpdated': true}, // Pass a flag to show success message on Home Screen
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while loading data
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade100,
                            // Priority: 1. Picked Image (local file), 2. Network Image (from Firestore URL), 3. Default Icon
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!) as ImageProvider<Object> // Use FileImage for local file
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!) as ImageProvider<Object> // Use NetworkImage for URL
                                    : null), // No background image if neither
                            child: _pickedImage == null && _profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.blue.shade700,
                                  )
                                : null, // Hide the default icon if an image is present
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.blue, size: 28),
                              onPressed: _pickImage, // Call the image picker method
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(), // Add border for better aesthetics
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Color.fromARGB(255, 198, 108, 108), // Changed to a standard light gray
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Email is typically read-only if managed by Firebase Auth
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.info_outline),
                        hintText: 'Tell us a bit about yourself...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _majorController,
                      decoration: const InputDecoration(
                        labelText: 'Major',
                        prefixIcon: Icon(Icons.school_outlined),
                        hintText: 'e.g., Computer Science, Business',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _batchController,
                      decoration: const InputDecoration(
                        labelText: 'Batch',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        hintText: 'e.g., 2025, Fall 2024',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600, // Custom button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Profile', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}