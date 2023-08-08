
class RegistrationCredentials {
  String name;
  String username;
  String email;
  String password;
  String dateOfBirth;
  String gender;

  RegistrationCredentials({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }
}
