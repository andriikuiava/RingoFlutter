import 'package:flutter/material.dart';
import 'Security/LoginPage.dart';
import 'UI/Themes.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';

void main() {
  runApp(
    MaterialApp(
      navigatorKey: App.materialKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const Directionality(
        textDirection: TextDirection.ltr,
        child: CheckerPage(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class App {
  static final GlobalKey<NavigatorState> materialKey = GlobalKey<NavigatorState>();
}
