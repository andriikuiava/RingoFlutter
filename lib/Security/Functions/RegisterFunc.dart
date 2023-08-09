import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Classes/RegistrationCredentialsClass.dart';
import 'package:ringoflutter/Security/Functions/LoginFunc.dart';
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';

Future<void> registerUser(RegistrationCredentials registrationCredentials) async {
  try {
    Uri url = Uri.parse('http://localhost:8080/api/participants/sign-up');
    var headers = {'Content-Type': 'application/json'};
    var jsonBody = jsonEncode(registrationCredentials.toJson());

    var response = await http.post(url, headers: headers, body: jsonBody);

    if (response.statusCode == 200) {
      print('User registered successfully');
      LoginCredentials loginCredentials = LoginCredentials(
        email: registrationCredentials.email,
        password: registrationCredentials.password,
      );
      loginFunc(loginCredentials);
    } else {
      print('User registration failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('An error occurred while registering user: $e');
  }
}
