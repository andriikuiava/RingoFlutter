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

class PopularForFeed extends StatefulWidget {
  const PopularForFeed({super.key});

  @override
  _PopularForFeedState createState() => _PopularForFeedState();
}

class _PopularForFeedState extends State<PopularForFeed>
    with TickerProviderStateMixin {
  final List<EventInFeed> _data = [];
  int _currentPage = 0;
  int nextRequest = 6;

  @override
  void initState() {
    super.initState();
    _fetchData(page: _currentPage);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_data.isNotEmpty && _data.length - 1 == nextRequest) {
        _fetchData(page: _currentPage + 1);
        nextRequest += 10;
      }
    });
  }

  Future<void> _fetchData({int page = 0}) async {
    var userCoordinates = await getUserLocation();
    checkTimestamp();
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    final url = Uri.parse(
        'http://localhost:8080/api/events?page=0&limit=5&latitude=${userCoordinates.latitude}&longitude=${userCoordinates.longitude}&sort=peopleCount');
    var headers = {
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> newData = jsonDecode(response.body);
      setState(() {
        _data.addAll(newData.map((item) =>
            EventInFeed.fromJson(item))); // Convert dynamic list to EventInFeed objects
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
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Prevent scrolling for the view
      itemCount: _data.length,
      itemBuilder: (context, index) {
        EventInFeed event = _data[index];
        return FractionallySizedBox(
          widthFactor: 0.92,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPage(eventId: event.id!),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: currentTheme.colorScheme.background,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "http://localhost:8080/api/photos/${event.mainPhotoId}",
                            width: 95,
                            height: 95,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: TextStyle(
                                  color: currentTheme.primaryColor,
                                  decoration: TextDecoration.none,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Text(
                                    " ${event.currency!.symbol}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${event.price}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.calendar_today,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    convertHourTimestamp(event.startTime!),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
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
                                    "${event.peopleCount} / ${event.capacity}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
