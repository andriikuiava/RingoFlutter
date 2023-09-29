import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  _SavedEventsScreenState createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  List<EventInFeed> eventsSaved = [];

  Future<List<EventInFeed>> getSavedEvents() async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    Uri url = Uri.parse(ApiEndpoints.GET_SAVED_EVENTS);
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse = customJsonDecode(response.body);
      List<EventInFeed> events = [];
      for (var eventJson in jsonResponse) {
        EventInFeed event = EventInFeed.fromJson(eventJson);
        events.add(event);
      }
      return events;
    } else {
      throw Exception('Failed to get saved events');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return VisibilityDetector(
      key: const Key("SavedEventsScreen"),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1) {
          getSavedEvents().then((value) {
            setState(() {
              eventsSaved = value;
            });
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                EdgeInsets.only(left: 0.01 * MediaQuery.of(context).size.width),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.bookmark_solid,
                  color: currentTheme.colorScheme.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Saved Events",
                  style: TextStyle(
                    color: currentTheme.colorScheme.primary,
                    fontSize: 32,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (eventsSaved.isEmpty && eventsSaved.length == 0)
            ClipRRect(
              borderRadius: defaultWidgetCornerRadius,
              child: Container(
                color: currentTheme.colorScheme.background,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.bookmark,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 0.7 * MediaQuery.of(context).size.width,
                        child: const Text(
                          "You don't have any saved events yet",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          FutureBuilder<List<EventInFeed>>(
            future: getSavedEvents(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                eventsSaved = snapshot.data!;
                return Column(
                  children: [
                    Column(
                      children: eventsSaved.map((event) {
                        return Column(
                          children: [
                            buildEvent(event),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              } else if (snapshot.hasError) {
                return Padding(
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
                );
              } else {
                return CircularProgressIndicator(
                  color: currentTheme.colorScheme.primary,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildEvent(EventInFeed event) {
    final currentTheme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (event.isActive) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => EventPage(eventId: event.id!),
            ),
          );
        } else {
          showErrorAlert("Error", "Event is not active", context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: defaultWidgetCornerRadius,
          color: currentTheme.colorScheme.background,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                borderRadius: defaultWidgetCornerRadius,
                child: Image.network(
                  '${ApiEndpoints.GET_PHOTO}/${event.mainPhotoId}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentTheme.colorScheme.primary,
                            fontSize: 18,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.location,
                              color: currentTheme.colorScheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              event.address!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: currentTheme.colorScheme.primary,
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar_today,
                              color: currentTheme.colorScheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              startTimeFromTimestamp(event.startTime!, null),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: currentTheme.colorScheme.primary,
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.normal,
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
                        (event.price == 0 || event.price == null)
                            ? 'Free'
                            : 'from ${event.currency!.symbol}${event.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: currentTheme.colorScheme.primary,
                          fontSize: 17,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
