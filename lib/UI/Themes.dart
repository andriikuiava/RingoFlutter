import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey.shade200,
  backgroundColor: Colors.white,
  shadowColor: Colors.grey.withOpacity(0.5)
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  backgroundColor: Colors.grey.shade900,
  shadowColor: Colors.grey.withOpacity(0.0)
);