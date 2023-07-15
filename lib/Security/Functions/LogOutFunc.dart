import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/LoginPage.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';



void logOut() {
  final storage = new FlutterSecureStorage();

  storage.deleteAll();

  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(builder: (_) => LoginPage()),
  );
}