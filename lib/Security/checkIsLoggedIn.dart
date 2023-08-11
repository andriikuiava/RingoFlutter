import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/main.dart';

final GlobalKey<NavigatorState> navigatorKey = App.materialKey;

void checkIsLoggedIn() async {
  const storage = FlutterSecureStorage();
  String currentTime = DateTime.now().toString();
  String? storedTime = await storage.read(key: 'timestamp');

  if (storedTime != null) {
    DateTime current = DateTime.parse(currentTime);
    DateTime stored = DateTime.parse(storedTime);

    if (current.compareTo(stored) > 0) {
      var token = await storage.read(key: 'refresh_token');
      checkIsLoggedIn();
        } else {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()),
      );
    }
  } else {
    throw Exception('No timestamp found');
  }
}
