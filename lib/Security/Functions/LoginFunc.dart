import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:ringoflutter/Home.dart';

Future<Tokens> loginFunc(BuildContext context, LoginCredentials loginCredentials) async {
  final Uri url = Uri.parse('http://localhost:8080/api/auth/login');
  final jsonBody = jsonEncode(loginCredentials.toJson());
  final headers = {'Content-Type': 'application/json'};

  final response = await http.post(url, headers: headers, body: jsonBody);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
    return Tokens(
      accessToken: jsonResponse['accessToken'],
      refreshToken: jsonResponse['refreshToken'],
    );
  } else {
    throw Exception('Failed to login');
  }
}
