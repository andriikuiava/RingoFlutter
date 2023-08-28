import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Classes/RegistrationCredentialsClass.dart';
import 'package:ringoflutter/Security/EmailVerificationPage.dart';
import 'package:ringoflutter/Security/Functions/LoginFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

Future<void> registerUser(RegistrationCredentials registrationCredentials, context) async {
  try {
    Uri url = Uri.parse('${ApiEndpoints.REGISTER}');
    var headers = {'Content-Type': 'application/json'};
    var jsonBody = jsonEncode(registrationCredentials.toJson());

    var response = await http.post(url, headers: headers, body: jsonBody);

    if (response.statusCode == 200) {
      print('User registered successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(usersEmail: registrationCredentials.email, usersUsername: registrationCredentials.username,),
        ),
      );
    } else if (response.statusCode == 400) {
      showErrorAlert("Error", response.body, context);
    } else {
      showErrorAlert("Error", "Error occurred while signing up", context);
      print('User registration failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('An error occurred while registering user: $e');
  }
}
