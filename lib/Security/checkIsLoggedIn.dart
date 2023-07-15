import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/Security/Functions/RefreshTokenFunc.dart';
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';
import 'package:ringoflutter/Home.dart';
import 'package:ringoflutter/main.dart';

final GlobalKey<NavigatorState> navigatorKey = App.materialKey;

void checkIsLoggedIn() async {
  final storage = FlutterSecureStorage();
  String currentTime = DateTime.now().toString();
  String? storedTime = await storage.read(key: 'timestamp');

  if (storedTime != null) {
    DateTime current = DateTime.parse(currentTime);
    DateTime stored = DateTime.parse(storedTime);

    if (current.compareTo(stored) > 0) {
      var token = await storage.read(key: 'refresh_token');
      refreshTokens(token!);
    } else {
      print(stored);
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => Home()),
      );
    }
  } else {
    throw Exception('No timestamp found');
  }
}
