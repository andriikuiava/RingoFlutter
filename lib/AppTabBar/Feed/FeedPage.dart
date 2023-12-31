import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/AppTabBar/Feed/Builder.dart';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/CategoryClass.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          'Feed',
          style: TextStyle(
            color: currentTheme.colorScheme.primary,
          ),
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          checkTimestamp();
          getFindGo();
          getPopularEvents();
          getCloseEvents();
          getCategories();
        },
        color: currentTheme.colorScheme.primary,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      'Nearby Adventures',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      onPressed: () async {
                        seeAll(context, "Nearby Adventures",
                            "sort=distance&dir=ASC");
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.colorScheme.primary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                nearbyAdventures(context),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      'Explore Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                exploreCategories(context),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      'Crowd Favorites',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      onPressed: () async {
                        seeAll(context, "Crowd Favorites",
                            "&sort=peopleCount&maxDistance=20000");
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.colorScheme.primary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                crowdFavorites(context),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      'Free Pass Events',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      onPressed: () async {
                        seeAll(context, "Free Pass Events",
                            "limit=20&isTicketNeeded=false&priceMax=0&currencyId=1");
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.colorScheme.primary,
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
      ),
    );
  }

  Future<List<EventInFeed>> getCloseEvents() async {
    var location = await getUserLocation();
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse(
        '${ApiEndpoints.SEARCH}?endTimeMin=${convertToUtc(DateTime.now())}&latitude=${location.latitude}&longitude=${location.longitude}&sort=distance');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = customJsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      print(response.body);
      throw Exception('Failed to load events');
    }
  }

  Widget nearbyAdventures(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<EventInFeed>>(
      future: getCloseEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: currentTheme.colorScheme.primary,
            ),
          );
        } else if (snapshot.hasError) {
          return noEvents(context);
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return noEvents(context);
        } else {
          return DefaultTabController(
            length: snapshot.data!.length,
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 1.4,
              child: Card(
                elevation: 0,
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
                      child: Center(child: eventCard(context, event, false)),
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

  Future<List<CategoryClass>> getCategories() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse(ApiEndpoints.GET_CATEGORY);
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var categoryList = customJsonDecode(response.body) as List<dynamic>;
      return categoryList.map((item) => CategoryClass.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Widget exploreCategories(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<CategoryClass>>(
      future: getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: currentTheme.colorScheme.primary,
            ),
          );
        } else if (snapshot.hasError) {
          return noEvents(context);
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Text(
            'No categories available.',
            style: TextStyle(
              decoration: TextDecoration.none,
              color: currentTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          );
        } else {
          return SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: snapshot.data!.map((category) {
                return Row(
                  children: [
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedBuilder(
                                    request:
                                        '${ApiEndpoints.SEARCH}?categoryIds=${category.id}&endTimeMin=${convertToUtc(DateTime.now())}',
                                    title: category.name,
                                  )),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: defaultWidgetCornerRadius,
                        child: Container(
                          color: currentTheme.colorScheme.background,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: currentTheme.colorScheme.primary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
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
        '${ApiEndpoints.SEARCH}?endTimeMin=${convertToUtc(DateTime.now())}&limit=20&isTicketNeeded=false&priceMax=0&currencyId=1');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = customJsonDecode(response.body) as List<dynamic>;
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
          return Center(
            child: CircularProgressIndicator(
              color: currentTheme.colorScheme.primary,
            ),
          );
        } else if (snapshot.hasError) {
          return noEvents(context);
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return Center(
            child: noEvents(context),
          );
        } else {
          return DefaultTabController(
            length: snapshot.data!.length,
            child: SizedBox(
              height: MediaQuery.of(context).size.width + 150,
              child: Card(
                elevation: 0,
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
                        child: eventCard(context, event, false),
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
    var location = await getUserLocation();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse(
        '${ApiEndpoints.SEARCH}?endTimeMin=${convertToUtc(DateTime.now())}&sort=peopleCount&latitude=${location.latitude}&longitude=${location.longitude}&limit=3&maxDistance=20000');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = customJsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Widget crowdFavorites(context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<List<EventInFeed>>(
      future: getPopularEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: currentTheme.colorScheme.primary,
            ),
          );
        } else if (snapshot.hasError) {
          return noEvents(context);
        } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
          return noEvents(context);
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
                              width: MediaQuery.of(context).size.width * 0.95,
                              color: currentTheme.colorScheme.background,
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
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                              0.95 -
                                          150,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.85 -
                                                70,
                                            child: Text(
                                              event.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: currentTheme
                                                    .colorScheme.primary,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.calendar_today,
                                                color: currentTheme
                                                    .colorScheme.primary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.7 -
                                                    80,
                                                child: Text(
                                                  startTimeFromTimestamp(
                                                      event.startTime!,
                                                      event.endTime!),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16,
                                                    color: currentTheme
                                                        .colorScheme.primary,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.person_2,
                                                color: currentTheme
                                                    .colorScheme.primary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "${event.peopleCount} / ${event.capacity}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: currentTheme
                                                      .colorScheme.primary,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${event.currency!.symbol} ${event.price}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              color: currentTheme
                                                  .colorScheme.primary,
                                              decoration: TextDecoration.none,
                                            ),
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
                }).toList() ??
                [], // Provide an empty list as a fallback
          );
        }
      },
    );
  }
}

Widget eventCard(context, EventInFeed event, bool isSelectedOnMap) {
  final currentTheme = Theme.of(context);
  return Column(
    children: [
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: defaultWidgetCornerRadius,
        child: Image.network(
          "${ApiEndpoints.GET_PHOTO}/${event.mainPhotoId}",
          width: MediaQuery.of(context).size.width - 20,
          height: MediaQuery.of(context).size.width - 20,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: defaultWidgetCornerRadius,
        child: Container(
          width: MediaQuery.of(context).size.width - 20,
          color: currentTheme.colorScheme.background,
          child: Padding(
            padding: defaultWidgetPadding,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.map_pin,
                          color: currentTheme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event.address!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: currentTheme.colorScheme.primary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    (event.distance != null)
                        ? Row(
                            children: [
                              Icon(
                                CupertinoIcons.location,
                                color: currentTheme.colorScheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                (isSelectedOnMap)
                                    ? "${convertToKilometersOrMeters(event.distance!)} from selected point"
                                    : "${convertToKilometersOrMeters(event.distance!)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(
                                CupertinoIcons.location,
                                color: currentTheme.colorScheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Location not available",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar_today,
                          color: currentTheme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          startTimeFromTimestamp(event.startTime!, null),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: currentTheme.colorScheme.primary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Text(
                    (event.price == 0)
                        ? "Free"
                        : "from ${event.currency!.symbol}${event.price!.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: currentTheme.colorScheme.primary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget noEvents(context) {
  final currentTheme = Theme.of(context);
  return Center(
    child: Padding(
      padding: defaultWidgetPadding,
      child: ClipRRect(
          borderRadius: defaultWidgetCornerRadius,
          child: Container(
            color: currentTheme.colorScheme.background,
            child: const Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Spacer(),
                    Text(
                      'No events available',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 20)
              ],
            ),
          )),
    ),
  );
}

void seeAll(context, String title, String params) async {
  var location = await getUserLocation();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FeedBuilder(
        request:
            "${ApiEndpoints.SEARCH}?latitude=${location.latitude}&longitude=${location.longitude}&$params&endTimeMin=${convertToUtc(DateTime.now())}",
        title: title,
      ),
    ),
  );
}
