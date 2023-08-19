import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'dart:async';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/api_endpoints.dart';

class TabBarForFeed extends StatefulWidget {
  const TabBarForFeed({super.key});

  @override
  _TabBarForFeedState createState() => _TabBarForFeedState();
}

class _TabBarForFeedState extends State<TabBarForFeed>
    with TickerProviderStateMixin {
  final List<EventInFeed> _data = [];
  int _currentPage = 0;
  late TabController _tabController;
  int _currentTabIndex = 0;
  int nextRequest = 6;

  @override
  void initState() {
    super.initState();
    _fetchData(page: _currentPage);

    _tabController = TabController(
      length: 30,
      vsync: this,
    );

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTabIndex == nextRequest) {
        _fetchData(page: _currentPage + 1);
        nextRequest += 10;
      }
    });

    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData({int page = 0}) async {
    var userCoordinates = await getUserLocation();
    checkTimestamp();
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    final url = Uri.parse(
        '${ApiEndpoints.SEARCH}?page=$page&limit=10&latitude=${userCoordinates.latitude}&longitude=${userCoordinates.longitude}&sort=distance');
    var headers = {
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> newData = jsonDecode(response.body);
      setState(() {
        _data.addAll(newData.map((item) => EventInFeed.fromJson(item))); // Convert dynamic list to EventInFeed objects
        _currentPage = page;
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Scaffold(
      body: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          children: [
            SizedBox(
              height: 0,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: List.generate(
                  _data.length,
                      (index) => Tab(text: 'Tab ${index + 1}'),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  _data.length,
                      (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventPage(
                              eventId: _data[index].id!,
                            ),
                          ),
                        );
                      },
                      child: SingleChildScrollView( // Use SingleChildScrollView instead of ListView
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                "${ApiEndpoints.GET_PHOTO}/${_data[index].mainPhotoId}",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(5),
                                color: currentTheme.colorScheme.background,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _data[index].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                        color: currentTheme.primaryColor,
                                      ),
                                    ),
                                    if (_data[index].distance != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.location,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${_data[index].distance!}m away",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    CupertinoIcons.map_pin,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${_data[index].address}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "${_data[index].currency!.symbol} ${_data[index].price}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    CupertinoIcons.calendar_today,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    convertHourTimestamp(_data[index].startTime!),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    CupertinoIcons.person_2_fill,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${_data[index].peopleCount}/${_data[index].capacity}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
