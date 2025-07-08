// lib/models/mentor_model.dart

class Mentor {
  final String id;
  final String name;
  final String major;
  final String batch;
  final String expertise;
  final String imageUrl; // Optional: for mentor's profile picture
  final String bio; // Optional: a short description

  Mentor({
    required this.id,
    required this.name,
    required this.major,
    required this.batch,
    required this.expertise,
    this.imageUrl = 'https://via.placeholder.com/150', // Default image
    this.bio = 'A dedicated mentor eager to help students succeed.',
  });

  // Factory constructor to create a Mentor from a Map (e.g., from Firestore)
  factory Mentor.fromMap(Map<String, dynamic> data, String id) {
    return Mentor(
      id: id,
      name: data['name'] ?? 'Unknown Mentor',
      major: data['major'] ?? 'N/A',
      batch: data['batch'] ?? 'N/A',
      expertise: data['expertise'] ?? 'General Advice',
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      bio: data['bio'] ?? 'A dedicated mentor eager to help students succeed.',
    );
  }

  // Method to convert Mentor object to a Map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'major': major,
      'batch': batch,
      'expertise': expertise,
      'imageUrl': imageUrl,
      'bio': bio,
    };
  }
}