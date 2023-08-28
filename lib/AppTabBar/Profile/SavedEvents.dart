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
    Uri url = Uri.parse('${ApiEndpoints.GET_SAVED_EVENTS}');
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
      key: Key("SavedEventsScreen"),
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
            padding: EdgeInsets.only(left: 0.01 * MediaQuery.of(context).size.width),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.bookmark_solid,
                  color: currentTheme.primaryColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Saved Events",
                  style: TextStyle(
                    color: currentTheme.primaryColor,
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
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('Failed to load events');
              } else {
                return const CircularProgressIndicator();
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
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EventPage(eventId: event.id!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: defaultWidgetCornerRadius,
          color: currentTheme.colorScheme.background,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: defaultWidgetCornerRadius,
              child: Image.network(
                '${ApiEndpoints.GET_PHOTO}/${event.mainPhotoId}',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentTheme.primaryColor,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_fill,
                          color: currentTheme.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.address!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: currentTheme.primaryColor,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${event.currency!.symbol} ${event.price}",
                          style: TextStyle(
                            color: currentTheme.primaryColor,
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: currentTheme.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          convertHourTimestamp(event.startTime!),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: currentTheme.primaryColor,
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal,
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
    );
  }
}
