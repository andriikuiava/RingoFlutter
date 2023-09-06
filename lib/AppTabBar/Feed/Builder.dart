import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/AppTabBar/Feed/FeedPage.dart';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';

class FeedBuilder extends StatefulWidget {
  final String request;
  final String? title;

  const FeedBuilder({Key? key, required this.request, this.title})
      : super(key: key);

  @override
  _FeedBuilderState createState() => _FeedBuilderState();
}

class _FeedBuilderState extends State<FeedBuilder> {
  List<EventInFeed> events = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    var userCoordinates = await getUserLocation();
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');
    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse('${widget.request}&page=$currentPage');
      print(url);
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = customJsonDecode(response.body);
        final List<EventInFeed> newEvents = data.map((item) =>
            EventInFeed.fromJson(item)).toList();

        setState(() {
          events.addAll(newEvents);
          isLoading = false;
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
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter == 0 &&
        !isLoading &&
        hasMoreData) {
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
        middle: Text(
          widget.title ?? 'Feed',
          style: TextStyle(
            color: currentTheme.primaryColor,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            CupertinoIcons.back,
            color: currentTheme.primaryColor,
            size: 24,
          ),
        ),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: ListView.builder(
          itemCount: events.length + 1,
          itemBuilder: (context, index) {
            if (index < events.length) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => EventPage(eventId: event.id!),
                    ),
                  );
                },
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    eventCard(context, event),
                  ],
                ),
              );
            } else if (isLoading) {
              return Center(child: CircularProgressIndicator(
                color: currentTheme.primaryColor,
              ));
            } else {
              return (events.length != 0)
                  ? Center(
                child: Padding(
                  padding: defaultWidgetPadding,
                  child: ClipRRect(
                      borderRadius: defaultWidgetCornerRadius,
                      child: Container(
                        color: currentTheme.backgroundColor,
                        child: const Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Spacer(),
                                Text('No more events available',
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
                      )
                  ),
                ),
              )
                  : Container();
            }
          },
        ),
      ),
    );
  }
}