import 'package:flutter/material.dart';
import 'Security/LoginPage.dart';
import 'UI/Themes.dart';

void main() {
  runApp(
    MaterialApp(
      navigatorKey: App.materialKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const Directionality(
        textDirection: TextDirection.ltr,
        child: LoginPage(),
        // child: FeedBuilder(key: UniqueKey(), request: "123"),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class App {
  static final GlobalKey<NavigatorState> materialKey = GlobalKey<NavigatorState>();
}
