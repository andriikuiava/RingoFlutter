import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Classes/OrganisationClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Classes/ReviewClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:ringoflutter/Classes/ContactCardClass.dart';

class HostPage extends StatefulWidget {
  final int hostId;

  const HostPage({Key? key, required this.hostId}) : super(key: key);

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> with TickerProviderStateMixin {
  late Future<Organisation> _organisationFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _organisationFuture = getHostById();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Organisation> getHostById() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('http://localhost:8080/api/organisations/${widget.hostId}');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return Organisation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load host');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<Organisation>(
      future: _organisationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CupertinoPageScaffold(
            backgroundColor: currentTheme.scaffoldBackgroundColor,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              middle: Text(
                "Organisation",
                style: TextStyle(
                  color: currentTheme.primaryColor,
                ),
              ),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  CupertinoIcons.back,
                  color: currentTheme.primaryColor,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: defaultWidgetCornerRadius,
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        color: currentTheme.colorScheme.background,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (snapshot.data!.profilePictureId != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage: NetworkImage(
                                          'http://localhost:8080/api/photos/${snapshot.data!.profilePictureId!}',
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        snapshot.data!.name,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: currentTheme.primaryColor,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "@${snapshot.data!.username}",
                                        style: const TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              snapshot.data!.description,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: currentTheme.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        )
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentTheme.scaffoldBackgroundColor,
                    ),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (context) => Container(
                          height: 370,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16,),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.contacts.length,
                                itemBuilder: (context, index) {
                                  ContactCard contactCard = snapshot.data!.contacts[index];
                                  bool _isNumeric(String str) {
                                    if (str == null) {
                                      return false;
                                    }
                                    return double.tryParse(str) != null;
                                  }

                                  IconData iconData;
                                  if (RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)').hasMatch(contactCard.content)) {
                                    iconData = CupertinoIcons.link;
                                  } else if (RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                      .hasMatch(contactCard.content)) {
                                    iconData = CupertinoIcons.mail;
                                  } else if (RegExp(r'^\+?[1-9][0-9\s-\(\)]{7,14}$').hasMatch(contactCard.content)) {
                                    iconData = CupertinoIcons.phone;
                                  } else {
                                    iconData = CupertinoIcons.doc_on_doc;
                                  }


                                  return GestureDetector(
                                    onTap: () async {
                                      if (iconData == CupertinoIcons.link) {
                                        launch(contactCard.content);
                                      } else if (iconData == CupertinoIcons.mail) {
                                        launch("mailto:${contactCard.content}");
                                      } else if (iconData == CupertinoIcons.phone) {
                                        launch("tel:${contactCard.content}");
                                      } else if (iconData == CupertinoIcons.doc_on_doc) {
                                        await Clipboard.setData(ClipboardData(text: contactCard.content));
                                        Fluttertoast.showToast(
                                          msg: "Copied to clipboard",
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: currentTheme.colorScheme.background,
                                          textColor: currentTheme.primaryColor,
                                          fontSize: 24,
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 10,),
                                            Icon(
                                              iconData,
                                              size: 16,
                                              color: currentTheme.primaryColor,
                                            ),
                                            SizedBox(width: 16,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  contactCard.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: currentTheme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  contactCard.content,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: currentTheme.primaryColor,
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Contact host",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: currentTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 60,
                  child: Card(
                    color: currentTheme.colorScheme.background,
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          height: 60,
                          child: Column(
                            children: [
                              Text(
                                '${snapshot.data!.rating}',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const Text('Rating'),
                            ],
                          ),
                        ),
                        Tab(
                          height: 60,
                          child: Column(
                            children: [
                              Text(
                                '${snapshot.data!.upcomingEventsCount}',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const Text('Upcoming'),
                            ],
                          ),
                        ),
                        Tab(
                          height: 60,
                          child: Column(
                            children: [
                              Text(
                                '${snapshot.data!.pastEventsCount}',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const Text('Past'),
                            ],
                          ),
                        ),
                      ],
                      labelColor: currentTheme.primaryColor,
                      unselectedLabelColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ratingSection(snapshot.data),
                      futureEventsSection(snapshot.data),
                      pastEventsSection(snapshot.data),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }


  Future<List<Review>> getReviewsByOrganisationId(int id) async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('http://localhost:8080/api/organisations/${widget.hostId}/reviews');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var reviewList = jsonDecode(response.body) as List<dynamic>;
      return reviewList.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Widget ratingSection(Organisation? data) {
    final currentTheme = Theme.of(context);
    return Expanded(
      child: Card(
        color: currentTheme.colorScheme.background,
        child: FutureBuilder<List<Review>>(
          future: getReviewsByOrganisationId(data?.id ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No reviews found.');
            } else {
              List<Review> reviews = snapshot.data!;
              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  var review = reviews[index];
                  return Container(
                    child: ListTile(
                      leading: review.participant.profilePictureId != null
                          ? CircleAvatar(
                        radius: 20.0,
                        backgroundImage: NetworkImage(
                          'http://localhost:8080/api/photos/${review.participant.profilePictureId!}',
                        ),
                      )
                          : CircleAvatar(
                        backgroundColor: currentTheme.primaryColor,
                        radius: 20.0,
                        child: Icon(
                          CupertinoIcons.person,
                          color: currentTheme.colorScheme.background,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(review.participant.name),
                          const Text(" • ",
                          style: TextStyle(
                            color: Colors.grey
                          ),),
                          Text("@${review.participant.username}",
                          style: const TextStyle(
                            color: Colors.grey
                          ),)
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.comment),
                          const Row(
                            //review.rate
                          )
                        ],
                      ),
                    ),
                    // You can add additional widgets here if needed.
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }



  Future<List<EventInFeed>> getUpcomingEvents(int id) async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('http://localhost:8080/api/events?hostId=${widget.hostId}&startTimeMin=${DateTime.now().toIso8601String()}');
    print(url);
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = jsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Widget futureEventsSection(Organisation? data) {
    final currentTheme = Theme.of(context);
    return Expanded(
      child: Card(
        color: currentTheme.colorScheme.background,
        child: FutureBuilder<List<EventInFeed>>(
          future: getUpcomingEvents(data?.id ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No events found.');
            } else {
              List<EventInFeed> events = snapshot.data!;
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventPage(eventId: event.id!),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: defaultWidgetCornerRadius,
                                child: Image.network(
                                    'http://localhost:8080/api/photos/${event.mainPhotoId}'
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Add some spacing between the image and text
                            Expanded(
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
                                      fontSize: 20,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.location_fill,
                                        color: currentTheme.primaryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          event.address!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: currentTheme.primaryColor,
                                            fontSize: 16,
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
                                          fontSize: 16,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                                        convertHourTimestamp(event.startTime!),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: currentTheme.primaryColor,
                                          fontSize: 16,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<EventInFeed>> getPastEvents(int id) async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('http://localhost:8080/api/events?hostId=${widget.hostId}&startTimeMax=${DateTime.now().toIso8601String()}');
    print(url);
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var eventList = jsonDecode(response.body) as List<dynamic>;
      return eventList.map((item) => EventInFeed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Widget pastEventsSection(Organisation? data) {
    final currentTheme = Theme.of(context);
    return Expanded(
      child: Card(
        color: currentTheme.colorScheme.background,
        child: FutureBuilder<List<EventInFeed>>(
          future: getPastEvents(data?.id ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No events found.');
            } else {
              List<EventInFeed> events = snapshot.data!;
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventPage(eventId: event.id!),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: ClipRRect(
                                  borderRadius: defaultWidgetCornerRadius,
                                  child: Image.network(
                                      'http://localhost:8080/api/photos/${event.mainPhotoId}'
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10), // Add some spacing between the image and text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.map_pin,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          event.address!,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          convertHourTimestamp(event.startTime!),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

}
