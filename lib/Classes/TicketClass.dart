import 'package:ringoflutter/Classes/UserClass.dart';
import 'package:ringoflutter/Classes/EventClass.dart';

class Ticket {
  User participant;
  EventInFeed event;
  String timeOfSubmission;
  String expiryDate;
  bool isValidated;
  String ticketCode;

  Ticket({
    required this.participant,
    required this.event,
    required this.timeOfSubmission,
    required this.expiryDate,
    required this.isValidated,
    required this.ticketCode,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      participant: User.fromJson(json['participant']),
      event: EventInFeed.fromJson(json['event']),
      timeOfSubmission: json['timeOfSubmission'],
      expiryDate: json['expiryDate'],
      isValidated: json['isValidated'],
      ticketCode: json['ticketCode'],
    );
  }
}
