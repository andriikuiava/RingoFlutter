import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Classes/CategoryClass.dart';
import 'package:ringoflutter/AppTabBar/Feed/Builder.dart';
import 'package:ringoflutter/api_endpoints.dart';

class FeedPage extends StatelessWidget {
  FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text('Feed',
        style: TextStyle(
          color: currentTheme.primaryColor,
        ),),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Close Events',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.primaryColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () async {
                      var location = await getUserLocation();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedBuilder(request:
                              "${ApiEndpoints.SEARCH}?latitude=${location.latitude}&longitude=${location.longitude}&limit=10&sort=distance",
                            title: "Close Events",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 16,
                        color: currentTheme.primaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              closeEvents(context),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Explore Categories',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.primaryColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              categoriesList(context),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Popular Events',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.primaryColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () async {
                      var location = await getUserLocation();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedBuilder(request:
                          "${ApiEndpoints.SEARCH}?latitude=${location.latitude}&longitude=${location.longitude}&limit=10&sort=peopleCount",
                            title: "Popular Events",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 16,
                        color: currentTheme.primaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              popularEvents(context),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Find & Go',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.primaryColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () async {
                      var location = await getUserLocation();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedBuilder(request:
                          "${ApiEndpoints.SEARCH}?latitude=${location.latitude}&longitude=${location.longitude}&limit=10&sort=distance&price=0",
                            title: "Find & Go",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 16,
                        color: currentTheme.primaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              findGo(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }


  Future<List<EventInFeed>> getCloseEvents() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse(
        '${ApiEndpoints.SEARCH}?startTimeMin=${DateTime.now()
            .toIso8601String()}&limit=20');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = jsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
  Widget closeEvents(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<EventInFeed>>(
      future: getCloseEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Text('No events available.');
        } else {
          return DefaultTabController(
            length: snapshot.data!.length,
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .width + 120,
              child: Card(
                color: Colors.transparent,
                child: TabBarView(
                  children: snapshot.data!.map((event) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventPage(eventId: event.id!),
                          ),
                        );
                      },
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: defaultWidgetCornerRadius,
                              child: Image.network(
                                "${ApiEndpoints.GET_PHOTO}/${event
                                    .mainPhotoId}",
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 20,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: defaultWidgetCornerRadius,
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 20,
                                color: currentTheme.backgroundColor,
                                child: Padding(
                                  padding: defaultWidgetPadding,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: currentTheme.primaryColor,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.map_pin,
                                            color: currentTheme.primaryColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            event.address!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: currentTheme.primaryColor,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${event.currency!.symbol} ${event
                                                .price}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: currentTheme.primaryColor,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.calendar,
                                            color: currentTheme.primaryColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            convertHourTimestamp(
                                                event.startTime!),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: currentTheme.primaryColor,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<Category>> getCategories() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('${ApiEndpoints.GET_CATEGORY}');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var categoryList = jsonDecode(response.body) as List<dynamic>;
      return categoryList.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
  Widget categoriesList(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<Category>>(
      future: getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Text('No categories available.');
        } else {
          return Container(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: snapshot.data!.map((category) {
                return Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FeedBuilder(request: '${ApiEndpoints.SEARCH}?category=${category.id}', title: category.name,)
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: defaultWidgetCornerRadius,
                            child: Container(
                              color: currentTheme.backgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: currentTheme.primaryColor,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    )
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Future<List<EventInFeed>> getFindGo() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse(
        '${ApiEndpoints.SEARCH}?startTimeMin=${DateTime.now()
            .toIso8601String()}&limit=20');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = jsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
  Widget findGo(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<EventInFeed>>(
      future: getFindGo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Text('No events available.');
        } else {
          return DefaultTabController(
            length: snapshot.data!.length,
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .width + 120,
              child: Card(
                color: Colors.transparent,
                child: TabBarView(
                  children: snapshot.data!.map((event) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventPage(eventId: event.id!),
                          ),
                        );
                      },
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: defaultWidgetCornerRadius,
                              child: Image.network(
                                "${ApiEndpoints.GET_PHOTO}/${event
                                    .mainPhotoId}",
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 20,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: defaultWidgetCornerRadius,
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 20,
                                color: currentTheme.backgroundColor,
                                child: Padding(
                                  padding: defaultWidgetPadding,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: currentTheme.primaryColor,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.map_pin,
                                            color: currentTheme.primaryColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            event.address!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: currentTheme.primaryColor,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${event.currency!.symbol} ${event
                                                .price}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: currentTheme.primaryColor,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.calendar,
                                            color: currentTheme.primaryColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            convertHourTimestamp(
                                                event.startTime!),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: currentTheme.primaryColor,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<EventInFeed>> getPopularEvents() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse(
        '${ApiEndpoints.SEARCH}?startTimeMin=${DateTime.now()
            .toIso8601String()}&limit=3');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = jsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
  Widget popularEvents(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<EventInFeed>>(
      future: getPopularEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Text('No events available.');
        } else {
          return Column(
            children: snapshot.data?.map((event) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPage(eventId: event.id!),
                    ),
                  );
                },
                child: Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: defaultWidgetCornerRadius,
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.95,
                            color: currentTheme.backgroundColor,
                            child: Padding(
                              padding: defaultWidgetPadding,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: defaultWidgetCornerRadius,
                                    child: Image.network(
                                      "${ApiEndpoints.GET_PHOTO}/${event.mainPhotoId}",
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.62,
                                    child: Column(
                                      children: [
                                        Text(
                                          event.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: currentTheme.primaryColor,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.calendar_today,
                                              color: currentTheme.primaryColor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              convertHourTimestamp(
                                                  event.startTime!),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 18,
                                                color: currentTheme.primaryColor,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.person_2,
                                              color: currentTheme.primaryColor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "${event.peopleCount} people going",
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 18,
                                                color: currentTheme.primaryColor,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              "${event.currency!.symbol} ${event
                                                  .price}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: currentTheme.primaryColor,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                ),
              );
            }).toList() ?? [], // Provide an empty list as a fallback
          );
        }
      },
    );
  }
}

