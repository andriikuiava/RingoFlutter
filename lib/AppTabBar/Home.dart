import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Profile/Profile.dart';
import 'Tickets/Tickets.dart';
import 'Map/MapPage.dart';
import 'Feed/FeedPage.dart';
import 'Search/SearchPage.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;

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
            icon: Icon(
              _selectedIndex == 2
                  ? CupertinoIcons.smallcircle_circle_fill
                  : CupertinoIcons.smallcircle_circle,
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
            tab = const MapPage();
            break;
          case 1:
            tab = const SearchPage();
            break;
          case 2:
            tab = const FeedPage();
            break;
          case 3:
            tab = const TicketsScreen();
            break;
          case 4:
            tab = const ProfileScreen();
            break;
        }
        return CupertinoTabView(builder: (context) => tab!);
      },
    );
  }
}