import 'package:flutter/material.dart';
import 'Security/LoginPage.dart';
import 'UI/Themes.dart';
// import 'package:ringoflutter/AppTabBar/Feed/test.dart';

void main() {
  runApp(
    MaterialApp(
      navigatorKey: App.materialKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: LoginPage(),
        // child: HomeScreen(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class App {
  static final GlobalKey<NavigatorState> materialKey = GlobalKey<NavigatorState>();
}