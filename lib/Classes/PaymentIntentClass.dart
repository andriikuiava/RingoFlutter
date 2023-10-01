import 'package:ringoflutter/Classes/TicketClass.dart';

class PaymentIntentResponse {
  String? paymentIntentClientSecret;
  String? organisationAccountId;
  Ticket? ticket;

  PaymentIntentResponse({
    this.paymentIntentClientSecret,
    this.organisationAccountId,
    this.ticket,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      paymentIntentClientSecret: json['paymentIntentClientSecret'],
      organisationAccountId: json['organisationAccountId'],
      ticket: json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null,
    );
  }
}