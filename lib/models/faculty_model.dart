class Faculty {
  final String name;
  final String department;
  final String role;
  final String? yearsAtUniversity; // Optional

  Faculty({
    required this.name,
    required this.department,
    required this.role,
    this.yearsAtUniversity,
  });
}