import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'dart:async';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/CoordinatesClass.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/Event/EventPage.dart';

class FeedBuilder extends StatefulWidget {
  final String request;

  const FeedBuilder({Key? key, required this.request}) : super(key: key);

  @override
  _FeedBuilderState createState() => _FeedBuilderState();
}

class _FeedBuilderState extends State<FeedBuilder> {
  List<EventInFeed> events = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMoreData = true; // Add this flag

  @override
  void initState() {
    super.initState();
    // Load initial data when the widget is first built
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    var userCoordinates = await getUserLocation();
    checkTimestamp();
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');
    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse(
          'http://localhost:8080/api/events?page=$currentPage&limit=10&latitude=${userCoordinates
              .latitude}&longitude=${userCoordinates.longitude}&sort=distance');
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<EventInFeed> newEvents = data.map((item) =>
            EventInFeed.fromJson(item)).toList();

        setState(() {
          events.addAll(newEvents);
          isLoading = false;
          // Check if the response has any events, if not, stop further requests
          hasMoreData = newEvents.isNotEmpty;
        });
      } else {
        // Handle the error scenario
        setState(() {
          isLoading = false;
        });
        print('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading events: $e');
    }
  }

  bool _onNotification(ScrollNotification notification) {
    // Check if the user has reached the end of the list and load more data if needed
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter == 0 &&
        !isLoading &&
        hasMoreData) { // Check if there's more data available before making a new request
      currentPage++;
      fetchEvents();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text('Feed'),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: ListView.builder(
          itemCount: events.length + 1,
          itemBuilder: (context, index) {
            if (index < events.length) {
              final event = events[index];
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: defaultWidgetCornerRadius,
                    // Adjust the corner radius as needed
                    child: Container(
                      child: Image.network(
                          "http://localhost:8080/api/photos/${event
                              .mainPhotoId}"),
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.93,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: defaultWidgetCornerRadius,
                    // Adjust the corner radius as needed
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.93,
                      color: currentTheme.backgroundColor,
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${event.name}",
                            style: TextStyle(
                              color: currentTheme.primaryColor,
                              decoration: TextDecoration.none,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.map_pin,
                                color: Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text("${event.address!}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar_today,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${convertHourTimestamp(event.startTime!)}",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${event.currency!.symbol} ${event.price}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          if (event.distance != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.location_fill,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${event.distance!}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_2_fill,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${event.peopleCount} / ${event.capacity}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          if (event.distance == null)
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.person_2_fill,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${event.peopleCount} / ${event.capacity}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.none,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            } else if (isLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              // When no more data to load
              return SizedBox();
            }
          },
        ),
      ),
    );
  }
}