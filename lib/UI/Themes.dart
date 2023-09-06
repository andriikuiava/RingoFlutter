import 'package:flutter/material.dart';

var defaultWidgetCornerRadius = BorderRadius.circular(12);
var defaultWidgetPadding = const EdgeInsets.all(12);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey.shade100,
  shadowColor: Colors.grey.withOpacity(0.5), colorScheme: const ColorScheme.light(error: Colors.red), bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey.shade100),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  shadowColor: Colors.grey.withOpacity(0.0), colorScheme: const ColorScheme.dark(error: Colors.red), bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey.shade900),
);