import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/Classes/TicketClass.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ringoflutter/Event/EventPage.dart';

class MyTicketPage extends StatefulWidget {
  final Ticket ticket;

  const MyTicketPage({Key? key, required this.ticket}) : super(key: key);

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventPage(
                                eventId: widget.ticket.event.id!,
                              ),
                            ),
                          );
                        },
                        child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child: ClipRRect(
                            borderRadius: defaultWidgetCornerRadius,
                            child: Container(
                              color: currentTheme.primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                        style: TextStyle(
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
                            color: currentTheme.backgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("NAME",
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
                                  Text("COST",
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
                                  Text("ADDRESS",
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
                                  Text("WAS BOUGHT",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text(convertHourTimestamp(widget.ticket.timeOfSubmission!),
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
