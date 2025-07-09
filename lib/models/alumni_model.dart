class Alumni {
  final String name;
  final int graduationYear;
  final String degreeMajor;
  final String occupation;
  final String company;
  final String? location; // Optional
  final String? contribution; // Optional

  Alumni({
    required this.name,
    required this.graduationYear,
    required this.degreeMajor,
    required this.occupation,
    required this.company,
    this.location,
    this.contribution,
  });
}