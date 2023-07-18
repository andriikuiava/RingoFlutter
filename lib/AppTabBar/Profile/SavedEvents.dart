import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/AppTabBar/Profile/Functions/GetEventsFunc.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({Key? key}) : super(key: key);

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Center(
            child: CupertinoButton(
              onPressed: () {
                checkTimestamp();
              },
              child: Text('Check Timestamp'),
            ),
          ),
        ],
      ),
    );
  }
}