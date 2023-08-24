import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:ringoflutter/Security/EmailVerificationPage.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';
import 'package:ringoflutter/api_endpoints.dart';


Future<Tokens> loginFunc(LoginCredentials loginCredentials) async {
  final Uri url = Uri.parse('${ApiEndpoints.LOGIN_RINGO}');
  final jsonBody = jsonEncode(loginCredentials.toJson());
  final headers = {'Content-Type': 'application/json'};

  final response = await http.post(url, headers: headers, body: jsonBody);
  const storage = FlutterSecureStorage();

  if (response.statusCode == 200) {
    final jsonResponse = customJsonDecode(response.body);
    DateTime currentTime = DateTime.now();
    DateTime futureTime =
    currentTime.add(const Duration(seconds: 30));
    storage.write(
        key: "timestamp",
        value: futureTime.toString());
    storage.write(
        key: "access_token",
        value: jsonResponse['accessToken']);
    storage.write(
        key: "refresh_token",
        value: jsonResponse['refreshToken']);

    Uri url = Uri.parse('${ApiEndpoints.CURRENT_PARTICIPANT}');
    var responseId = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${jsonResponse['accessToken']}'
    });
    if (responseId.statusCode == 200) {
      final jsonResponse = customJsonDecode(responseId.body);
      print(jsonResponse);
      storage.write(
          key: "id",
          value: jsonResponse['id'].toString());
      if (jsonResponse['emailVerified']) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const Home()),
        );
      } else {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => EmailVerificationPage(usersEmail: jsonResponse['email'],)),
        );
      }
    } else {
      throw Exception('Failed to load participants');
    }

    return Tokens(
      accessToken: jsonResponse['accessToken'],
      refreshToken: jsonResponse['refreshToken'],
    );
  } else {
    throw Exception('Failed to login');
  }
}
