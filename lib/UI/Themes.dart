import 'package:flutter/material.dart';

var defaultWidgetCornerRadius = BorderRadius.circular(12);
var defaultWidgetPadding = EdgeInsets.all(12);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey.shade200,
  backgroundColor: Colors.white,
  shadowColor: Colors.grey.withOpacity(0.5),
  bottomAppBarColor: Colors.grey.shade200,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black,
  backgroundColor: Colors.grey.shade900,
  shadowColor: Colors.grey.withOpacity(0.0),
  bottomAppBarColor: Colors.grey.shade900,
);