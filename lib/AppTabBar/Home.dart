import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Feed/FeedPage.dart';
import 'Map/MapPage.dart';
import 'Profile/Profile.dart';
import 'Search/SearchPage.dart';
import 'Tickets/Tickets.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: currentTheme.primaryColor,
        iconSize: 26,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 0
                  ? CupertinoIcons.map_fill
                  : CupertinoIcons.map,
            ),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              child: Image.asset(
                _selectedIndex == 2
                    ? (currentTheme.brightness == Brightness.dark
                    ? 'assets/images/ringo-tab-white.png'
                    : 'assets/images/ringo-tab-black.png')
                    : 'assets/images/ringo-tab-grey.png',
              ),
            ),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3
                  ? CupertinoIcons.tickets_fill
                  : CupertinoIcons.tickets,
            ),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 4
                  ? CupertinoIcons.person_fill
                  : CupertinoIcons.person,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        Widget? tab;
        switch (index) {
          case 0:
            tab = MapPage();
            break;
          case 1:
            tab = SearchPage();
            break;
          case 2:
            tab = FeedPage();
            break;
          case 3:
            tab = TicketsScreen();
            break;
          case 4:
            tab = ProfileScreen();
            break;
        }
        return CupertinoTabView(builder: (context) => tab!);
      },
    );
  }
}