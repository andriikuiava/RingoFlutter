import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


Future<Tokens> loginFunc(LoginCredentials loginCredentials) async {
  final Uri url = Uri.parse('http://localhost:8080/api/auth/login');
  final jsonBody = jsonEncode(loginCredentials.toJson());
  final headers = {'Content-Type': 'application/json'};

  final response = await http.post(url, headers: headers, body: jsonBody);
  final storage = new FlutterSecureStorage();

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => Home()),
    );

    DateTime currentTime = DateTime.now();
    DateTime futureTime =
    currentTime.add(Duration(minutes: 5));
    storage.write(
        key: "timestamp",
        value: futureTime.toString());

    return Tokens(
      accessToken: jsonResponse['accessToken'],
      refreshToken: jsonResponse['refreshToken'],
    );
  } else {
    throw Exception('Failed to login');
  }
}
