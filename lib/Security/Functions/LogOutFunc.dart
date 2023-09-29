import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/LoginPage.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

void logOut() {
  const storage = FlutterSecureStorage();

  storage.deleteAll();
  SharedPreferences.getInstance().then((prefs) {
    prefs.clear();
  });

  navigatorKey.currentState?.pushReplacement(
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
}
