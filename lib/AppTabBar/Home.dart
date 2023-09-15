import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Feed/FeedPage.dart';
import 'Map/MapPage.dart';
import 'Profile/Profile.dart';
import 'Search/SearchPage.dart';
import 'Tickets/Tickets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const MapPage(),
    const SearchPage(),
    const FeedPage(),
    const TicketsScreen(),
    const ProfileScreen(),
  ];

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
  List.generate(5, (_) => GlobalKey<NavigatorState>());

  void _onTabTapped(int index) {
    if (index == _selectedIndex) {
      // If the same tab is tapped again, pop all routes on its Navigator stack.
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = CupertinoTheme.of(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor.withOpacity(0.8),
        activeColor: (currentTheme.brightness == Brightness.dark)
            ? Colors.white
            : Colors.black,
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
            icon: Icon(CupertinoIcons.search,
                size: 26,),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2
                  ? (currentTheme.brightness == Brightness.dark)
                    ? 'assets/images/ringo-tab-white.png'
                    : 'assets/images/ringo-tab-black.png'
                  : 'assets/images/ringo-tab-grey.png',
              width: 26,
              height: 26,
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
        onTap: _onTabTapped,
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          navigatorKey: _navigatorKeys[index],
          builder: (BuildContext context) => _pages[index],
        );
      },
    );
  }
}
