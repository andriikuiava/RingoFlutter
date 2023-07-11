import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'LoginPage.dart';

void main() {
  runApp(
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr, // or TextDirection.rtl if applicable
        child: LoginPage(),
      ),
    ),
  );
}
