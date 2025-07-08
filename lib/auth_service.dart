// lib/auth_service.dart
// This file provides a service layer for Firebase Authentication operations.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for potential future use or if you save user data here

class AuthService {
  // Get an instance of Firebase Authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Renamed to _firebaseAuth for consistency
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Added for consistency

  // Stream to listen to authentication state changes
  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  // Method to sign up a new user with email and password.
  // Returns the UserCredential object if successful, otherwise throws FirebaseAuthException.
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // You can choose to save initial user data here or in the signup_screen
      // For example:
      // await _firestore.collection('users').doc(userCredential.user!.uid).set({
      //   'uid': userCredential.user!.uid,
      //   'email': email,
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      return userCredential; // Return the UserCredential
    } on FirebaseAuthException {
      // Re-throw the FirebaseAuthException so the UI can catch and display specific errors
      rethrow;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Method to sign in an existing user with email and password.
  // Returns the UserCredential object if successful, otherwise throws FirebaseAuthException.
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential; // Return the UserCredential
    } on FirebaseAuthException {
      // Re-throw the FirebaseAuthException so the UI can catch and display specific errors
      rethrow;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Method to sign out the currently authenticated user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Method to get the currently authenticated user (convenience method)
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}