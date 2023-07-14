import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'UI/Themes.dart';
import 'Security/LoginPage.dart';

void main() {
  runApp(
    MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: LoginPage(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
