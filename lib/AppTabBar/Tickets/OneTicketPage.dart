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
            color: currentTheme.colorScheme.primary,
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
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 5,),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: ClipRRect(
                            borderRadius: defaultWidgetCornerRadius,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: currentTheme.colorScheme.primary,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (!widget.ticket.isValidated && widget.ticket.event.isActive) {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => EventPage(
                                                eventId: widget.ticket.event.id!,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.6,
                                            child: Text(widget.ticket.event.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: currentTheme
                                                      .scaffoldBackgroundColor,
                                                  decoration: TextDecoration.none,
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(startTimeFromTimestamp(widget.ticket.event.startTime!, null),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                decoration: TextDecoration.none,
                                              )
                                          ),
                                          (widget.ticket.ticketType != null)
                                          ? Column(
                                            children: [
                                              const SizedBox(height: 2,),
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.6,
                                                child: Text("Type: ${widget.ticket.ticketType!.title}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey,
                                                      decoration: TextDecoration.none,
                                                    )
                                                ),
                                              ),
                                            ],
                                          )
                                          : Container(),
                                          const SizedBox(height: 1,),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    (checkIfExpired(widget.ticket.expiryDate) || isTimestampInThePast(widget.ticket.event.endTime!) || widget.ticket.isValidated)
                                    ? CupertinoButton(
                                      onPressed: () {
                                        deleteTicket(context);
                                      },
                                      child: Icon(
                                        CupertinoIcons.delete,
                                        color: currentTheme.scaffoldBackgroundColor,
                                      ),
                                    )
                                    : CupertinoButton(
                                      child: Icon(
                                        CupertinoIcons.calendar_badge_plus,
                                        color: currentTheme.scaffoldBackgroundColor,
                                      ),
                                      onPressed: () {
                                        final Event event = Event(
                                          title: widget.ticket.event.name,
                                          description: widget.ticket.event.description,
                                          location: widget.ticket.event.address,
                                          iosParams: IOSParams(
                                            reminder: const Duration(hours: 12),
                                            url: "https://ringo-events.com/event/${widget.ticket.event.id!}",
                                          ),
                                          startDate: DateTime.parse(widget.ticket.event.startTime!),
                                          endDate: DateTime.parse(widget.ticket.event.endTime!),
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
                                        color: currentTheme.colorScheme.primary,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  const SizedBox(height: 7,),
                                  const Text("PRICE",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  Text("${widget.ticket.ticketType!.currency.symbol}${widget.ticket.ticketType!.price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.colorScheme.primary,
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
                                        color: currentTheme.colorScheme.primary,
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
                                  Text(startTimeFromTimestamp(widget.ticket.timeOfSubmission, null),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.colorScheme.primary,
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
                                  Text(startTimeFromTimestamp(widget.ticket.expiryDate, null),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentTheme.colorScheme.primary,
                                        decoration: TextDecoration.none,
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
                                          CupertinoPageRoute(
                                              builder: (BuildContext context) {
                                                return CupertinoPageScaffold(
                                                  child: Center(
                                                    child: Container(
                                                      height: MediaQuery.of(context).size.height * 0.9,
                                                      child: Column(
                                                        children: [
                                                          Spacer(),
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(9),
                                                            child: QrImageView(
                                                              data: widget.ticket.ticketCode,
                                                              backgroundColor: Colors.white,
                                                              dataModuleStyle: QrDataModuleStyle(
                                                                dataModuleShape: QrDataModuleShape.square,
                                                                color: (widget.ticket.isValidated) ? Colors.grey : Colors.black,
                                                              ),
                                                              eyeStyle: QrEyeStyle(
                                                                eyeShape: QrEyeShape.square,
                                                                color: (widget.ticket.isValidated) ? Colors.grey : Colors.black,
                                                              ),
                                                              size: MediaQuery.of(context).size.width * 0.95,
                                                              version: QrVersions.auto,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 20,),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.7,
                                                            child: CupertinoButton(
                                                              color: currentTheme.colorScheme.background,
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text(
                                                                "Close",
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: currentTheme.colorScheme.primary,
                                                                  decoration: TextDecoration.none,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                          ) );
                                    },
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: QrImageView(
                                          data: widget.ticket.ticketCode,
                                          backgroundColor: Colors.white,
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: QrDataModuleShape.square,
                                            color: (widget.ticket.isValidated) ? Colors.grey : Colors.black,
                                          ),
                                          eyeStyle: QrEyeStyle(
                                            eyeShape: QrEyeShape.square,
                                            color: (widget.ticket.isValidated) ? Colors.grey : Colors.black,
                                          ),
                                          size: MediaQuery.of(context).size.width * 0.7,
                                          version: QrVersions.auto,
                                        ),
                                      ),
                                    ),
                                  ),
                                  (widget.ticket.isValidated)
                                  ? Column(
                                    children: [
                                      const SizedBox(height: 10,),
                                      Center(
                                        child: Text(
                                          "This ticket has been validated",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Container(),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            color: currentTheme.colorScheme.background,
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
                                  const Spacer(),
                                  Icon(
                                    isAnswersExpanded
                                        ? CupertinoIcons.chevron_up
                                        : CupertinoIcons.chevron_down,
                                    color: currentTheme.colorScheme.primary,
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
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: (isAnswersExpanded)
                            ? FractionallySizedBox(
                          widthFactor: 0.9,
                          child: ClipRRect(
                            borderRadius: defaultWidgetCornerRadius,
                            child: Container(
                              color: currentTheme.colorScheme.background,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
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
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "${question.content}${question.required ? ' *' : ''}",
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTheme.colorScheme.primary,
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
              color: currentTheme.colorScheme.background,
              borderRadius: BorderRadius.circular(8.0),
            ),
            controller: TextEditingController(
              text: answers.firstWhere((answer) => answer.questionId == question.id).content,
            ),
            padding: const EdgeInsets.all(16),
            style: TextStyle(
              fontSize: 16,
              color: currentTheme.colorScheme.primary,
            ),
            cursorColor: currentTheme.colorScheme.primary
          ),
        ],
      ),
    );
  }

  Widget buildMultipleChoiceQuestion(Question question) {
    var currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  "${question.content}${question.required ? ' *' : ''}",
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? CupertinoIcons.smallcircle_fill_circle
                          : CupertinoIcons.circle,
                      color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? currentTheme.colorScheme.primary
                          : currentTheme.colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      option.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                            ? currentTheme.colorScheme.primary
                            : currentTheme.colorScheme.primary.withOpacity(0.3),
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
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              "${question.content}${question.required ? ' *' : ''}",
              style: TextStyle(
                fontSize: 16,
                color: currentTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? CupertinoIcons.checkmark_square_fill
                          : CupertinoIcons.square,
                      color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                          ? currentTheme.colorScheme.primary
                          : currentTheme.colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      option.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                            ? currentTheme.colorScheme.primary
                            : currentTheme.colorScheme.primary.withOpacity(0.3),
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
