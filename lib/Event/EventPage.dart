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
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:social_share/social_share.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ringoflutter/Event/StickerPageToShare.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ringoflutter/AppTabBar/Feed/Builder.dart';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:image/image.dart' as img;

class EventPage extends StatefulWidget {
  final int eventId;

  const EventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int index = 0;
  GoogleMapController? _controller;
  String? _mapStyle;
  String? _mapStyleIos;
  String? _mapStyleDark;
  String? _mapStyleIosDark;

  bool isDescriptionExpanded = false;

  @override
  void initState() {
    rootBundle.loadString('assets/map/light.txt').then((string) {
      _mapStyle = string;
    });

    rootBundle.loadString('assets/map/dark.txt').then((string) {
      _mapStyleDark = string;
    });

    rootBundle.loadString('assets/map/light.json').then((string) {
      _mapStyleIos = string;
    });

    rootBundle.loadString('assets/map/dark.json').then((string) {
      _mapStyleIosDark = string;
    });

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
    const storage = FlutterSecureStorage();

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
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      if (isSaved) {
        showUnsavedAlert(context);
      } else {
        showSavedAlert(context);
      }
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
      final wasDeleted = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyTicketPage(
            ticket: ticket,
          ),
        ),
      );
      if (wasDeleted) {
        _refreshEvent();
      }
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
                    color: currentTheme.colorScheme.primary,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () async {
                    String facebookAppId = "1020391179152310";
                    var availableApps = await SocialShare.checkInstalledAppsForShare();
                    var file = await DefaultCacheManager().getSingleFile("${ApiEndpoints.GET_PHOTO}/${event.mainPhoto.mediumQualityId}");
                    print(availableApps);
                    await showPullDownMenu(
                      context: context,
                      items: [
                        if (availableApps!["instagram"] == true)
                          PullDownMenuItem(
                            title: 'Add to Instagram Story',
                            onTap: () async {
                              await SocialShare.shareInstagramStory(
                                appId: facebookAppId,
                                imagePath: file.path,
                                backgroundTopColor: "#ffffff",
                                backgroundBottomColor: "#000000",
                                backgroundResourcePath: "assets/images/Ringo-Black.png",
                                attributionURL: "https://ringo-events.com/event/${event.id}",
                              ).then((data) {
                                print(data);
                              });
                            },
                          ),
                        if (availableApps["facebook"] == true)
                          PullDownMenuItem(
                            title: 'Add to Facebook Story',
                            onTap: () async {
                              await SocialShare.shareFacebookStory(
                                appId: facebookAppId,
                                attributionURL: "https://ringo-events.com/event/${event.id}",
                                imagePath: file.path,
                                backgroundTopColor: "#ffffff",
                                backgroundBottomColor: "#000000",
                              ).then((data) {
                                print(data);
                              });
                            },
                          ),
                        PullDownMenuItem(
                          title: 'Other options',
                          onTap: () async {
                            final result = await Share.shareXFiles(
                              [
                                XFile(file.path,),
                              ],
                              text: "Check out ${event.name} by ${event.host.name} on Ringo!\nhttps://ringo-events.com/event/${event.id}",
                            );
                          },
                        ),
                      ],
                        position: Rect.fromCenter(
                          center: Offset(MediaQuery.of(context).size.width - 50, 50),
                          width: 0,
                          height: 0,
                        ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.share,
                    color: currentTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.back,
                    color: currentTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              child: RefreshIndicator(
                onRefresh: _refreshEvent,
                color: currentTheme.colorScheme.primary,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: defaultWidgetPadding,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
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
                                    color: currentTheme.colorScheme.primary,
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
                                        Column(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: (event.host.profilePictureId != null)
                                                  ? CircleAvatar(
                                                backgroundColor: currentTheme.colorScheme.primary,
                                                radius: 32.0,
                                                backgroundImage: NetworkImage(
                                                  '${ApiEndpoints.GET_PHOTO}/${event.host.profilePictureId}',
                                                ),
                                              ) : CircleAvatar(
                                                backgroundColor: currentTheme.colorScheme.background,
                                                backgroundImage: Image.asset(
                                                    (currentTheme.brightness == Brightness.light)
                                                        ? "assets/images/Ringo-Black.png"
                                                        : "assets/images/Ringo-White.png"
                                                ).image,
                                                radius: 32.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.69,
                                              child: Text(
                                                event.host.name,
                                                style: TextStyle(
                                                  color: currentTheme.colorScheme.primary,
                                                  decoration:
                                                  TextDecoration.none,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                                //big button
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: (event.isTicketNeeded && !isTimestampInThePast(event.endTime!))
                                      ? ElevatedButton(
                                    onPressed: () async {
                                      if (!event.isRegistered) {
                                        if (event.ticketTypes != [] && event.ticketTypes != null) {
                                          showModalBottomSheet<void>(
                                            context: context,
                                            elevation: 0,
                                            builder: (context) =>
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: event.ticketTypes!.length,
                                                  itemBuilder: (context, index) {
                                                    return GestureDetector(
                                                        onTap: () async {
                                                          if (!isSoldOut(event.ticketTypes![index])) {
                                                            Navigator.pop(context);
                                                            final wasBought = await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => FormCompletion(
                                                                  event: event,
                                                                  selectedTicketType: event.ticketTypes![index].id,
                                                                ),
                                                              ),
                                                            );
                                                            if (wasBought) {
                                                              _refreshEvent();
                                                            }
                                                          }
                                                        },
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(height: 10,),
                                                            ListTile(
                                                              title: Text(
                                                                "${event.ticketTypes![index].title}",
                                                                style: TextStyle(
                                                                  color: currentTheme.colorScheme.primary,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                constructDescription(event.ticketTypes![index]),
                                                                style: TextStyle(
                                                                  color: currentTheme.colorScheme.primary,
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              trailing: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12),
                                                                child: Container(
                                                                  color: isSoldOut(event.ticketTypes![index])
                                                                      ? Colors.grey
                                                                      : currentTheme.colorScheme.primary,
                                                                  width: 70,
                                                                  height: 50,
                                                                  child: Center(
                                                                    child: FittedBox(
                                                                      fit: BoxFit.scaleDown,
                                                                      alignment: Alignment.center,
                                                                      child: Text(
                                                                        (isSoldOut(event.ticketTypes![index]))
                                                                            ? " Sold out! "
                                                                            : ((event.ticketTypes![index].price == 0))
                                                                            ? "Free"
                                                                            : "${event.ticketTypes![index].currency.symbol}${event.ticketTypes![index].price.toStringAsFixed(2)}",
                                                                        style: TextStyle(
                                                                          color: currentTheme.scaffoldBackgroundColor,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10,),
                                                            const Divider(
                                                              color: Colors.grey,
                                                              height: 0,
                                                              thickness: 0.5,
                                                            ),
                                                          ],
                                                        )
                                                    );
                                                  },
                                                ),
                                          );
                                        } else {
                                          final wasBought = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FormCompletion(
                                                event: event,
                                                selectedTicketType: 0,
                                              ),
                                            ),
                                          );
                                          if (wasBought) {
                                            _refreshEvent();
                                          }
                                        }
                                      } else {
                                        getBoughtTicket();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      foregroundColor: currentTheme.colorScheme.primary,
                                      backgroundColor: currentTheme.colorScheme.primary,
                                    ),
                                    child: !event.isRegistered
                                        ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              (event.ticketTypes == null || event.ticketTypes == [] ? "Get Ticket" : "Buy ticket"),
                                              style: TextStyle(
                                                color: currentTheme.scaffoldBackgroundColor,
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
                                              constructPrice(event),
                                              style: TextStyle(
                                                color: currentTheme.scaffoldBackgroundColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                        : Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              ("Open Ticket"),
                                              style: TextStyle(
                                                color: currentTheme.scaffoldBackgroundColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : SizedBox(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.41,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              foregroundColor: currentTheme.colorScheme.primary,
                                              backgroundColor: currentTheme.scaffoldBackgroundColor,
                                            ),
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Icon(
                                                  (event.isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark),
                                                  size: 16,
                                                  color: currentTheme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4,),
                                                Text(
                                                  (event.isSaved ? "Unsave" : "Save"),
                                                  style: TextStyle(
                                                    color: currentTheme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                            onPressed: () {
                                              saveEvent(event.isSaved);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.07,),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.41,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: currentTheme.colorScheme.primary,
                                              elevation: 0,
                                              backgroundColor: (event.host.contacts.isNotEmpty ? currentTheme.scaffoldBackgroundColor : Colors.grey),
                                            ),
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Text(
                                                  ("Contact host"),
                                                  style: TextStyle(
                                                    color: (event.host.contacts.isNotEmpty ? currentTheme.colorScheme.primary : Colors.grey.shade50),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                            onPressed: () {
                                              if (event.host.contacts.isEmpty) {
                                                null;
                                              } else {
                                                showModalBottomSheet<void>(
                                                  context: context,
                                                  elevation: 0,
                                                  builder: (context) => SizedBox(
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
                                                            bool isNumeric(String str) {
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
                                                                  String phoneNumber = contactCard.content.replaceAll(RegExp(r'[^0-9]'), '');
                                                                  launch("tel:$phoneNumber");
                                                                } else if (iconData == CupertinoIcons.doc_on_doc) {
                                                                  await Clipboard.setData(ClipboardData(text: contactCard.content));
                                                                  Fluttertoast.showToast(
                                                                    msg: "Copied to clipboard",
                                                                    gravity: ToastGravity.CENTER,
                                                                    backgroundColor: currentTheme.colorScheme.background,
                                                                    textColor: currentTheme.colorScheme.primary,
                                                                    fontSize: 24,
                                                                  );
                                                                }
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(10.0),
                                                                child: SizedBox(
                                                                  width: MediaQuery.of(context).size.width * 0.9,
                                                                  child: Row(
                                                                    children: [
                                                                      const SizedBox(width: 10,),
                                                                      Icon(
                                                                        iconData,
                                                                        size: 16,
                                                                        color: currentTheme.colorScheme.primary,
                                                                      ),
                                                                      const SizedBox(width: 16,),
                                                                      Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            contactCard.title,
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                              color: currentTheme.colorScheme.primary,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                          (iconData == CupertinoIcons.link)
                                                                              ? Text(
                                                                            contactCard.content,
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: const TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.normal,
                                                                              fontSize: 16,
                                                                            ),
                                                                          )
                                                                              : Text(
                                                                            contactCard.content,
                                                                            style: TextStyle(
                                                                              color: currentTheme.colorScheme.primary,
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
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width,
                        child: PageView.builder(
                          onPageChanged: (value) {
                            setState(() {
                              index = value;
                            });
                          },
                          itemCount: imgList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Center(
                                  child: Image.network(
                                    imgList[index],
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (event.photos.isNotEmpty)
                        Column(
                          children: [
                            PageViewDotIndicator(
                              currentItem: index,
                              count: imgList.length,
                              unselectedColor: Colors.grey,
                              selectedColor: currentTheme.colorScheme.primary,
                              size: const Size(8, 6),
                              duration: const Duration(milliseconds: 200),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: defaultWidgetCornerRadius,
                          child: Stack(
                            children: [
                              GoogleMap(
                                onMapCreated: (GoogleMapController controller) {
                                  _controller = controller;
                                  (Platform.isAndroid)
                                      ? (currentTheme.brightness == Brightness.light)
                                      ? _controller?.setMapStyle(_mapStyle!)
                                      : _controller?.setMapStyle(_mapStyleDark!)
                                      : (currentTheme.brightness == Brightness.light)
                                      ? _controller?.setMapStyle(_mapStyleIos!)
                                      : _controller?.setMapStyle(_mapStyleIosDark!);
                                },
                                myLocationButtonEnabled: false,
                                buildingsEnabled: true,
                                mapType: MapType.normal,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(event.coordinates!.latitude, event.coordinates!.longitude),
                                  zoom: 10.0,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(event.name),
                                    position: LatLng(event.coordinates!.latitude, event.coordinates!.longitude),
                                    draggable: true,
                                  )
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  color: Colors.transparent,
                                  constraints: const BoxConstraints.expand(),

                                ),
                                onTap: () {
                                  launch("https://www.google.com/maps/search/?api=1&query=${event.coordinates!.latitude},${event.coordinates!.longitude}");
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: defaultWidgetPadding,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isDescriptionExpanded = !isDescriptionExpanded;
                                    });
                                  },
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: (isDescriptionExpanded)
                                        ? Text((event.description!),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.colorScheme.primary,
                                      ),
                                    )
                                        : Text((event.description!),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.clock_fill,
                                      size: 17,
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text(startTimeFromTimestamp(event.startTime!, event.endTime!),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6,),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.map_pin,
                                      size: 17,
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text((event.address!),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.colorScheme.primary,
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
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text((
                                        (event.capacity != null)
                                        ? "People going: ${event.peopleCount}/${event.capacity}"
                                        : "People going: ${event.peopleCount}"),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: currentTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (event.categories != null)
                                  Column(
                                    children: [
                                      const SizedBox(height: 6,),
                                      Container(
                                        height: 30,
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(event.categories!.length, (index) {
                                              return Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      var location = await getUserLocation();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FeedBuilder(request: '${ApiEndpoints.SEARCH}?categoryIds=${event.categories![index].id}&endTimeMin=${convertToUtc(DateTime.now())}&latitude=${location.latitude}&longitude=${location.longitude}&sort=distance&dir=ASC', title: event.categories![index].name,),
                                                        ),
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: Container(
                                                        color: (currentTheme.brightness == Brightness.light)
                                                            ? Colors.grey.shade200
                                                            : Colors.grey.shade700,
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(width: 8,),
                                                            Icon(
                                                              CupertinoIcons.list_bullet_below_rectangle,
                                                              size: 17,
                                                              color: currentTheme.colorScheme.primary,
                                                            ),
                                                            const SizedBox(width: 6,),
                                                            Text(
                                                              event.categories![index].name,
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                color: currentTheme.colorScheme.primary,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8,),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10,),
                                                ],
                                              );
                                            }),
                                          ),
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
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading event",
              style: TextStyle(
                fontSize: 24,
                color: currentTheme.colorScheme.primary
              ),
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: currentTheme.colorScheme.primary,
          ),
        );
      },
    );
  }
}
