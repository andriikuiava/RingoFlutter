import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ringoflutter/Classes/TicketClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';
import 'package:ringoflutter/Classes/Answer.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class MyTicketPage extends StatefulWidget {
  final Ticket ticket;

  const MyTicketPage({Key? key, required this.ticket}) : super(key: key);

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {

  List<Answer> answers = [];
  bool isAnswersExpanded = false;

  void loadAnswers() async {
    answers = widget.ticket.registrationSubmission!.answers!;
  }

  @override
  void initState() {
    super.initState();
    loadAnswers();
  }

  void deleteTicket(BuildContext context) async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    Uri url = Uri.parse('${ApiEndpoints.SEARCH}/${widget.ticket.event.id!}/${ApiEndpoints.LEAVE}');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      print(response.statusCode);
      print(response.body);
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
            size: 24,
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
                              padding: EdgeInsets.all(8),
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
                                    (checkIfExpired(widget.ticket.expiryDate) || widget.ticket.event.price == 0)
                                    ? CupertinoButton(
                                      onPressed: () {
                                        deleteTicket(context);
                                      },
                                      child: Icon(
                                        CupertinoIcons.delete,
                                        color: currentTheme.backgroundColor,
                                      ),
                                    )
                                    : CupertinoButton(
                                      child: Icon(
                                        CupertinoIcons.calendar_badge_plus,
                                        color: currentTheme.backgroundColor,
                                      ),
                                      onPressed: () {
                                        final Event event = Event(
                                          title: widget.ticket.event.name,
                                          description: widget.ticket.event.description,
                                          location: widget.ticket.event.address,
                                          iosParams: IOSParams(
                                            reminder: Duration(hours: 12),
                                            url: "https://ringo-events.com/event/${widget.ticket.event.id!}",
                                          ),
                                          startDate: DateTime.parse("${widget.ticket.event.startTime!}"),
                                          endDate: DateTime.parse("${widget.ticket.event.endTime!}"),
                                        );
                                        Add2Calendar.addEvent2Cal(event);
                                      },
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
                            color: currentTheme.backgroundColor,
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
                                  Text("${widget.ticket.event.currency!.symbol}${widget.ticket.event.price!.toStringAsFixed(2)}",
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
                                  const Text("ISSUED AT",
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
                                  const SizedBox(height: 7,),
                                  const Text("EXPIRES AT",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text(convertHourTimestamp(widget.ticket.expiryDate),
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
                      const SizedBox(height: 10,),
                      (widget.ticket.registrationForm != null)
                      ? FractionallySizedBox(
                        widthFactor: 0.9,
                        child: ClipRRect(
                          borderRadius: defaultWidgetCornerRadius,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            color: currentTheme.backgroundColor,
                            child: CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  isAnswersExpanded = !isAnswersExpanded;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Registration Form",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: currentTheme
                                          .primaryColor,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    isAnswersExpanded
                                        ? CupertinoIcons.chevron_up
                                        : CupertinoIcons.chevron_down,
                                    color: currentTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      : Container(),
                      const SizedBox(height: 10,),
                      AnimatedSize(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: (isAnswersExpanded)
                            ? FractionallySizedBox(
                          widthFactor: 0.9,
                          child: ClipRRect(
                            borderRadius: defaultWidgetCornerRadius,
                            child: Container(
                              color: currentTheme.backgroundColor,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.ticket.registrationForm!.questions.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final question = widget.ticket.registrationForm!.questions[index];
                                  switch (question.type) {
                                    case "INPUT_FIELD":
                                      return buildInputFieldQuestion(question);
                                    case "MULTIPLE_CHOICE":
                                      return buildMultipleChoiceQuestion(question);
                                    case "CHECKBOX":
                                      return buildCheckboxQuestion(question);
                                    default:
                                      return Container();
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                            : Container(),
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
  Widget buildInputFieldQuestion(Question question) {
    final currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "${question.content}${question.required ? ' *' : ''}",
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          CupertinoTextField(
            enabled: false,
            maxLength: question.maxCharacters,
            decoration: BoxDecoration(
              color: currentTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            controller: TextEditingController(
              text: answers.firstWhere((answer) => answer.questionId == question.id).content,
            ),
            padding: EdgeInsets.all(16),
            style: TextStyle(
              fontSize: 16,
              color: currentTheme.primaryColor,
            ),
            cursorColor: currentTheme.primaryColor
          ),
        ],
      ),
    );
  }

  Widget buildMultipleChoiceQuestion(Question question) {
    var currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  "${question.content}${question.required ? ' *' : ''}",
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? CupertinoIcons.smallcircle_fill_circle
                          : CupertinoIcons.circle,
                      color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? currentTheme.primaryColor
                          : currentTheme.primaryColor.withOpacity(0.3),
                    ),
                    SizedBox(width: 16),
                    Text(
                      option.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                            ? currentTheme.primaryColor
                            : currentTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildCheckboxQuestion(Question question) {
    var currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              "${question.content}${question.required ? ' *' : ''}",
              style: TextStyle(
                fontSize: 16,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? CupertinoIcons.checkmark_square_fill
                          : CupertinoIcons.square,
                      color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? currentTheme.primaryColor
                          : currentTheme.primaryColor.withOpacity(0.3),
                    ),
                    SizedBox(width: 16),
                    Text(
                      option.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                            ? currentTheme.primaryColor
                            : currentTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
