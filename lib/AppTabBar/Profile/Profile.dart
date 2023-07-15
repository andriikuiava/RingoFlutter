import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    // logOut();
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        trailing: Icon(
          CupertinoIcons.settings,
          size: 26,
          color: currentTheme.primaryColor,
        ),
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          'Profile',
          style: TextStyle(
            color: currentTheme.primaryColor,
          ),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Text('Element 1'),
                Text('Element 2'),
                Text('Element 3'),
                // Add more text elements as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
