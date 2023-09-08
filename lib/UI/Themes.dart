import 'package:flutter/material.dart';

var defaultWidgetCornerRadius = BorderRadius.circular(12);
var defaultWidgetPadding = const EdgeInsets.all(12);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey.shade100,
  shadowColor: Colors.grey.withOpacity(0.5),
  colorScheme: const ColorScheme.light(
      error: Colors.red,
      background: Colors.white,
      primary: Colors.black,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  shadowColor: Colors.grey.withOpacity(0.0),
  colorScheme: ColorScheme.dark(
      error: Colors.red,
      background: Colors.grey.shade900.withOpacity(0.5),
      primary: Colors.white,
  ),
);