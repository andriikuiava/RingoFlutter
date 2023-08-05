import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/AppTabBar/Feed/EventsNearYou.dart';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/CoordinatesClass.dart';
import 'package:ringoflutter/AppTabBar/Feed/Popular.dart';
import 'package:ringoflutter/AppTabBar/Feed/Builder.dart';


class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    var userCoordinates = getUserLocation();
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text('Feed'),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left side
          children: [
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Popular events",
                  style: TextStyle(
                    color: currentTheme.primaryColor,
                    decoration: TextDecoration.none,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
