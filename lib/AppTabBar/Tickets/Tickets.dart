import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Classes/TicketClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/AppTabBar/Tickets/OneTicketPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {

  @override
  void initState() {
    super.initState();
    loadTicketsFromStorage();
  }

  void loadTicketsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedTicketsFromStorage = prefs.getStringList('tickets') ?? [];
    setState(() {
      savedTickets = savedTicketsFromStorage;
      ticketsFromStorage = savedTicketsFromStorage.map((ticketJson) => Ticket.fromJson(json.decode(ticketJson))).toList();
    });
  }

  List<Ticket> myTickets = [];
  List<String> savedTickets = [];
  List<Ticket> ticketsFromStorage = [];

  Future<List<Ticket>> getMyTickets() async {
    await checkTimestamp();
    List<String> savedTicketsToSave = [];
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    Uri url = Uri.parse('http://localhost:8080/api/tickets');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<Ticket> tickets = [];
      for (var ticketJson in jsonResponse) {
        savedTicketsToSave.add(json.encode(ticketJson));
        Ticket ticket = Ticket.fromJson(ticketJson);
        tickets.add(ticket);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('tickets', savedTicketsToSave);
      return tickets;
    } else {
      throw Exception('Failed to get tickets');
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: VisibilityDetector(
          key: Key("ticketsVisibilityDetector"),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction == 1.0) {
              setState(() {
                myTickets = [];
                getMyTickets().then((tickets) {
                  setState(() {
                    myTickets = tickets;
                  });
                });
              });
            }
          },
          child: Text(
            'Tickets',
            style: TextStyle(
              color: currentTheme.primaryColor,
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: FutureBuilder<List<Ticket>>(
          future: getMyTickets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ticketsFromStorage.length > 0 ? ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: ticketsFromStorage.length,
                itemBuilder: (context, int index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyTicketPage(
                                  ticket: ticketsFromStorage[index],
                                ),
                              ),
                            );
                          },
                          child: buildTicketWithoutPhoto(ticketsFromStorage[index]),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 0),
              ) : const Center(child: Text('No tickets'));
            } else {
              if (snapshot.data == null) {
                return const Center(child: Text('No tickets'));
              } else {
                List<Ticket> myTickets = snapshot.data ?? [];
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: myTickets.length,
                  itemBuilder: (context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyTicketPage(
                                    ticket: myTickets[index],
                                  ),
                                ),
                              );
                            },
                            child: buildTicket(myTickets[index]),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 0),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildTicket(Ticket ticket) {
    void deleteTicket(BuildContext context) async {
      await checkTimestamp();
      var storage = const FlutterSecureStorage();
      var token = await storage.read(key: "access_token");
      Uri url = Uri.parse('http://localhost:8080/api/events/${ticket.event.id!}/leave');
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          myTickets.remove(ticket);
        });
      } else {
        throw Exception('Failed to delete ticket');
      }
    }
    final currentTheme = Theme.of(context);
    return Slidable(
      endActionPane: ActionPane(
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            borderRadius: defaultWidgetCornerRadius,
            autoClose: true,
            onPressed: deleteTicket,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
          decoration: BoxDecoration(
            color: currentTheme.colorScheme.background,
            borderRadius: defaultWidgetCornerRadius,
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 0.2 * MediaQuery.of(context).size.width,
                height: 0.2 * MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: defaultWidgetCornerRadius,
                  image: DecorationImage(
                    image: NetworkImage("http://localhost:8080/api/photos/${ticket.event.mainPhotoId}"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 0.65 * MediaQuery.of(context).size.width,
                    child: Text(ticket.event.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          color: currentTheme.primaryColor,
                        )
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        color: currentTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(convertHourTimestamp(ticket.event.startTime!),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                            color: currentTheme.primaryColor,
                          )
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.location_fill,
                        color: currentTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        ticket.event.address!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                          color: currentTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.circle_fill,
                        color: (ticket.isValidated) ? Colors.red : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        (ticket.isValidated) ? "Invalid" : "Valid",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                          color: currentTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
  Widget buildTicketWithoutPhoto(Ticket ticket) {
    final currentTheme = Theme.of(context);
    return Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.background,
          borderRadius: defaultWidgetCornerRadius,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: QrImageView(
                data: ticket.ticketCode,
                backgroundColor: Colors.white,
                size: MediaQuery.of(context).size.width * 0.2,
                version: QrVersions.auto,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 0.65 * MediaQuery.of(context).size.width,
                  child: Text(ticket.event.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: currentTheme.primaryColor,
                      )
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Icon(
                      CupertinoIcons.calendar,
                      color: currentTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(convertHourTimestamp(ticket.event.startTime!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                          color: currentTheme.primaryColor,
                        )
                    ),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.location_fill,
                      color: currentTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      ticket.event.address!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        color: currentTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
    );
  }
}
