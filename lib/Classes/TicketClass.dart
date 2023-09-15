import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Classes/UserClass.dart';
import 'package:ringoflutter/Classes/Answer.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';
import 'package:ringoflutter/Classes/TicketTypeClass.dart';

class Ticket {
  User participant;
  EventInFeed event;
  String timeOfSubmission;
  String expiryDate;
  bool isValidated;
  String ticketCode;
  TicketType? ticketType;
  RegistrationForm? registrationForm;
  RegistrationSubmission? registrationSubmission;


  Ticket({
    required this.participant,
    required this.event,
    required this.timeOfSubmission,
    required this.expiryDate,
    required this.isValidated,
    required this.ticketCode,
    this.ticketType,
    this.registrationForm,
    this.registrationSubmission
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      participant: User.fromJson(json['participant']),
      event: EventInFeed.fromJson(json['event']),
      timeOfSubmission: json['timeOfSubmission'],
      expiryDate: json['expiryDate'],
      isValidated: json['isValidated'],
      ticketCode: json['ticketCode'],
      ticketType: json['ticketType'] != null ? TicketType.fromJson(json['ticketType']) : null,
      registrationForm: json['registrationForm'] != null ? RegistrationForm.fromJson(json['registrationForm']) : null,
      registrationSubmission: json['registrationSubmission'] != null ? RegistrationSubmission.fromJson(json['registrationSubmission']) : null,
    );
  }
}

class RegistrationSubmission {
  List<Answer>? answers;

  RegistrationSubmission({
    this.answers,
  });

  factory RegistrationSubmission.fromJson(Map<String, dynamic> json) {
    List<dynamic>? answersJson = json['answers'];

    List<Answer>? answers;
    if (answersJson != null) {
      answers = answersJson.map((answerJson) {
        return Answer.fromJson(answerJson);
      }).toList();
    }

    return RegistrationSubmission(answers: answers);
  }
}