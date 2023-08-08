import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/LoginPage.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';



void logOut() {
  const storage = FlutterSecureStorage();

  storage.deleteAll();

  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
}