import 'package:ringoflutter/Classes/CurrencyClass.dart';


class TicketType {
  int id;
  String title;
  String? description;
  double price;
  Currency currency;
  int peopleCount;
  int? maxTickets;
  String? salesStopTime;

  TicketType({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.currency,
    required this.peopleCount,
    this.maxTickets,
    this.salesStopTime,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      currency: Currency.fromJson(json['currency']),
      peopleCount: json['peopleCount'],
      maxTickets: json['maxTickets'],
      salesStopTime: json['salesStopTime'],
    );
  }
}