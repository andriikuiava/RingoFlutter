class LoginCredentials {
  String email;
  String password;

  LoginCredentials({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
