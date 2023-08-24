import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/AppTabBar/Tickets/OneTicketPage.dart';
import 'package:ringoflutter/Classes/ContactCardClass.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Classes/TicketClass.dart';
import 'package:ringoflutter/Event/FormCompletion.dart';
import 'package:ringoflutter/Host/HostPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:url_launcher/url_launcher.dart';


class EventPage extends StatefulWidget {
  final int eventId;

  const EventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<EventFull> getEvent() async {
    await checkTimestamp();
    final storage = FlutterSecureStorage();

    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('${ApiEndpoints.SEARCH}/${widget.eventId}');

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = customJsonDecode(response.body);
      EventFull event = EventFull.fromJson(jsonResponse);
      return event;
    } else {
      throw Exception('Failed to get event');
    }
  }


  Future<EventFull> saveEvent(bool isSaved) async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = (isSaved ? Uri.parse('${ApiEndpoints.SEARCH}/${widget.eventId}/${ApiEndpoints.UNSAVE}') : Uri.parse('${ApiEndpoints.SEARCH}/${widget.eventId}/${ApiEndpoints.SAVE}'));
    print(url);
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      _refreshEvent();
      var jsonResponse = customJsonDecode(response.body);
      EventFull event = EventFull.fromJson(jsonResponse);
      return event;
    } else {
      throw Exception('Failed to get event');
    }
  }

  Future<EventFull> getTicketNoForm() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('${ApiEndpoints.SEARCH}/${widget.eventId}/${ApiEndpoints.JOIN}');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.post(url, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      _refreshEvent();
      var jsonResponse = customJsonDecode(response.body);
      EventFull event = EventFull.fromJson(jsonResponse);
      return event;
    } else {
      throw Exception('Failed to get event');
    }
  }

  void getBoughtTicket() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('${ApiEndpoints.SEARCH}/${widget.eventId}/${ApiEndpoints.GET_TICKET}');
    var headers = {'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'};

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse = customJsonDecode(response.body);
      Ticket ticket = Ticket.fromJson(jsonResponse);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyTicketPage(ticket: ticket),
        ),
      );
    } else {
      throw Exception('Failed to get ticket');
    }
  }

  Future<void> _refreshEvent() async {
    try {
      EventFull event = await getEvent();
      setState(() {
        event = event;
      });
    } catch (e) {
      print('Error refreshing event: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<EventFull>(
      future: getEvent(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          EventFull event = snapshot.data!;
          List<String> imgList = [];
          imgList.add("${ApiEndpoints.GET_PHOTO}/${event.mainPhoto.mediumQualityId}");
          for(var photoLoop in event.photos) {
            imgList.add("${ApiEndpoints.GET_PHOTO}/${photoLoop.normalId}");
          }

          return Material(
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: currentTheme.scaffoldBackgroundColor,
                middle: Text(
                  "Event",
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
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: defaultWidgetPadding,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: currentTheme.colorScheme.background,
                            borderRadius: defaultWidgetCornerRadius,
                          ),
                          constraints: const BoxConstraints(maxWidth: double.infinity),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: TextStyle(
                                    color: currentTheme.primaryColor,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HostPage(
                                            hostId: event.host.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (event.host.profilePictureId != null)
                                          Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: CircleAvatar(
                                              radius: 32.0,
                                              backgroundImage: NetworkImage(
                                                '${ApiEndpoints.GET_PHOTO}/${event.host.profilePictureId}',
                                              ),
                                            ),
                                          ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.host.name,
                                              style: TextStyle(
                                                color: currentTheme.primaryColor,
                                                decoration:
                                                TextDecoration.none,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "@${event.host.username}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                decoration:
                                                TextDecoration.none,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!event.isRegistered) {
                                        if (event.registrationForm == null) {
                                          getTicketNoForm();
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FormCompletion(
                                                form: event.registrationForm!,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        getBoughtTicket();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentTheme.primaryColor,
                                    ),
                                    child: !event.isRegistered
                                    ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              (event.price == 0.0 ? "Get Ticket" : "Buy Ticket"),
                                              style: TextStyle(
                                                color: currentTheme.colorScheme.background,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              (event.price == 0.0 ? "Free" : "${event.currency!.symbol} ${event.price}"),
                                              style: TextStyle(
                                                color: currentTheme.colorScheme.background,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          ("Open Ticket"),
                                          style: TextStyle(
                                            color: currentTheme.colorScheme.background,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (event.host.contacts.isNotEmpty)
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.43,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: currentTheme.scaffoldBackgroundColor,
                                            ),
                                            child: Text(
                                              "Contact host",
                                              style: TextStyle(
                                                color: currentTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
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
                                                        itemCount: event.host.contacts.length,
                                                        itemBuilder: (context, index) {
                                                          ContactCard contactCard = event.host.contacts[index];
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
                                                                        (iconData == CupertinoIcons.link)
                                                                            ? Text(
                                                                          contactCard.content,
                                                                          maxLines: 1,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                            color: Colors.blue,
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 16,
                                                                          ),
                                                                        )
                                                                            : Text(
                                                                          contactCard.content,
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
                                          ),
                                        ),
                                      const SizedBox(height: 6,),
                                      SizedBox(
                                        width: (event.host.contacts.isNotEmpty) ? MediaQuery.of(context).size.width * 0.43 : MediaQuery.of(context).size.width * 0.9,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: currentTheme.colorScheme.background,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  event.isSaved ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark,
                                                  size: 16,
                                                  color: currentTheme.primaryColor,
                                                ),
                                                const SizedBox(width: 4,),
                                                Text(
                                                  event.isSaved ? "Saved" : "Save",
                                                  style: TextStyle(
                                                    color: currentTheme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onPressed: () async {
                                            event = await saveEvent(event.isSaved);
                                            Fluttertoast.showToast(
                                              msg: event.isSaved ? "Event was removed from saved" : "Event was added to saved",
                                              gravity: ToastGravity.CENTER,
                                              backgroundColor: currentTheme.colorScheme.background,
                                              textColor: currentTheme.primaryColor,
                                              fontSize: 24,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width,
                        child: PageView.builder(
                          itemCount: imgList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Center(
                                child: Image.network(
                                  imgList[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 160,
                        child: ClipRRect(
                          borderRadius: defaultWidgetCornerRadius,
                          child: GoogleMap(
                            myLocationButtonEnabled: false,
                            buildingsEnabled: true,
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(event.coordinates!.latitude, event.coordinates!.longitude),
                              zoom: 16.0,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(event.name),
                                position: LatLng(event.coordinates!.latitude, event.coordinates!.longitude),
                                draggable: true,
                              )
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: defaultWidgetPadding,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: currentTheme.colorScheme.background,
                            borderRadius: defaultWidgetCornerRadius,
                          ),
                          constraints: const BoxConstraints(maxWidth: double.infinity),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((event.description!),
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: currentTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 6,),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.clock_fill,
                                      size: 17,
                                      color: currentTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text(convertHourTimestamp(event.startTime!),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6,),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.location_fill,
                                      size: 17,
                                      color: currentTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text((event.address!),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6,),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_2_fill,
                                      size: 17,
                                      color: currentTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text(("People going: ${event.peopleCount}/${event.capacity}"),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 90,
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load event'),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
