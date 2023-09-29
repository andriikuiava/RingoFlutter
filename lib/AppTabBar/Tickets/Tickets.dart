import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ringoflutter/AppTabBar/Tickets/OneTicketPage.dart';
import 'package:ringoflutter/Classes/TicketClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<Ticket> tickets = [];

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  void loadTickets() async {
    if (await InternetConnectionChecker().hasConnection == true) {
      await checkTimestamp();
      var storage = const FlutterSecureStorage();
      var url = Uri.parse(ApiEndpoints.GET_TICKETS);
      var token = await storage.read(key: "access_token");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (response.statusCode == 200) {
        var decoded = customJsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('tickets', response.body);
        setState(() {
          for (var ticket in decoded) {
            tickets.add(Ticket.fromJson(ticket));
          }
        });
      } else {
        print(response.statusCode);
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var ticketsString = prefs.getString('tickets');
      if (ticketsString != null) {
        var decoded = customJsonDecode(ticketsString);
        setState(() {
          for (var ticket in decoded) {
            tickets.add(Ticket.fromJson(ticket));
          }
        });
      }
    }
  }

  void _refreshTickets() async {
    await checkTimestamp();
    setState(() {
      tickets.clear();
    });

    loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          'Tickets',
          style: TextStyle(
            color: currentTheme.colorScheme.primary,
          ),
        ),
      ),
      child: RefreshIndicator(
        color: currentTheme.colorScheme.primary,
        child: (tickets.isNotEmpty)
            ? ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  var ticket = tickets[index];
                  return GestureDetector(
                    onTap: () async {
                      final wasDeleted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyTicketPage(ticket: ticket)),
                      );
                      if (wasDeleted == true) {
                        _refreshTickets();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 8),
                      child: Card(
                          color: currentTheme.colorScheme.background,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: defaultWidgetCornerRadius,
                                  child: Image.network(
                                      "${ApiEndpoints.GET_PHOTO}/${ticket.event.mainPhotoId}",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover, errorBuilder:
                                          (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                    return Image.asset(
                                      (currentTheme.brightness ==
                                              Brightness.light)
                                          ? 'assets/images/Ringo-Black.png'
                                          : 'assets/images/Ringo-White.png',
                                      width: 80,
                                      height: 80,
                                    );
                                  }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          ticket.event.name,
                                          style: TextStyle(
                                            color: currentTheme
                                                .colorScheme.primary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.map,
                                            color: Colors.grey,
                                            size: 14,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            ticket.event.address ??
                                                'No address provided',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            CupertinoIcons.circle_fill,
                                            color: ticket.isValidated
                                                ? Colors.red
                                                : isTimestampInThePast(
                                                        ticket.event.endTime!)
                                                    ? Colors.yellow
                                                    : Colors.green,
                                            size: 14,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            ticket.isValidated
                                                ? 'Validated'
                                                : isTimestampInThePast(
                                                        ticket.event.endTime!)
                                                    ? 'Expired'
                                                    : 'Valid',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.calendar,
                                            color: Colors.grey,
                                            size: 14,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            startTimeFromTimestamp(
                                                ticket.event.startTime!, null),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${ticket.ticketType!.currency.symbol}${ticket.ticketType!.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  );
                },
              )
            : ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3),
                          const Icon(
                            CupertinoIcons.tickets_fill,
                            color: Colors.grey,
                            size: 100,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'You have no tickets yet',
                            style: TextStyle(
                              wordSpacing: 1.5,
                              color: Colors.grey,
                              fontSize: 20,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.arrow_down,
                                color: Colors.grey,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Pull to refresh',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
        onRefresh: () async {
          await checkTimestamp();
          _refreshTickets();
        },
      ),
    );
  }
}
