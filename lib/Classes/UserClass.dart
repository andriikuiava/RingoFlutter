class User {
  int id;
  String email;
  String name;
  String username;
  int profilePicture;
  bool isActive;
  String dateOfBirth;
  String gender;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    required this.profilePicture,
    required this.isActive,
    required this.dateOfBirth,
    required this.gender,
  });
}