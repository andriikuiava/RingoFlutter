import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/Classes/TicketClass.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';

class MyTicketPage extends StatefulWidget {
  final Ticket ticket;

  const MyTicketPage({Key? key, required this.ticket}) : super(key: key);

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {
  void deleteTicket(BuildContext context) async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    Uri url = Uri.parse('http://localhost:8080/api/events/${widget.ticket.event.id!}/leave');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      throw Exception('Failed to delete ticket');
    }
  }
  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          "Ticket",
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
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 5,),
                Center(
                  child: Column(
                    children: [
                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: ClipRRect(
                            borderRadius: defaultWidgetCornerRadius,
                            child: Container(
                              color: currentTheme.primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => EventPage(
                                              eventId: widget.ticket.event.id!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.ticket.event.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: currentTheme
                                                    .scaffoldBackgroundColor,
                                                decoration: TextDecoration.none,
                                              )
                                          ),
                                          const SizedBox(height: 2,),
                                          Text(convertHourTimestamp(widget.ticket.event.startTime!),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                decoration: TextDecoration.none,
                                              )
                                          ),
                                          const SizedBox(height: 1,),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    CupertinoButton(
                                      onPressed: () {
                                        deleteTicket(context);
                                      },
                                      child: Icon(
                                        CupertinoIcons.delete,
                                        color: currentTheme.backgroundColor,
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10,),
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: ClipRRect(
                          borderRadius: defaultWidgetCornerRadius,
                          child: Container(
                            color: currentTheme.colorScheme.background,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("NAME",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text(widget.ticket.participant.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.primaryColor,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  const SizedBox(height: 7,),
                                  const Text("COST",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text("${widget.ticket.event.currency!.symbol} ${widget.ticket.event.price!}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.primaryColor,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  const SizedBox(height: 7,),
                                  const Text("ADDRESS",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text(widget.ticket.event.address!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.primaryColor,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  const SizedBox(height: 7,),
                                  const Text("WAS BOUGHT",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text(convertHourTimestamp(widget.ticket.timeOfSubmission),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.primaryColor,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: QrImageView(
                                        data: widget.ticket.ticketCode,
                                        backgroundColor: Colors.white,
                                        size: MediaQuery.of(context).size.width * 0.7,
                                        version: QrVersions.auto,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
