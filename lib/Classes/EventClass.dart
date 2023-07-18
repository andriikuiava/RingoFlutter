import 'dart:convert';
import 'package:ringoflutter/Classes/PhotoClasses.dart';
import 'package:ringoflutter/Classes/CoordinatesClass.dart';
import 'package:ringoflutter/Classes/CategoryClass.dart';
import 'package:ringoflutter/Classes/CurrencyClass.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';
import 'package:ringoflutter/Classes/OrganisationClass.dart';

class EventInFeed {
  int id;
  String name;
  String? description;
  bool isActive;
  String? address;
  Coordinates? coordinates;
  int mainPhotoId;
  double? distance;
  bool isTicketNeeded;
  double? price;
  Currency? currency;
  String? startTime;
  String? endTime;
  List<Category>? categories;
  int? hostId;
  int peopleCount;
  int capacity;

  EventInFeed({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.address,
    this.coordinates,
    required this.mainPhotoId,
    this.distance,
    required this.isTicketNeeded,
    this.price,
    this.currency,
    this.startTime,
    this.endTime,
    this.categories,
    this.hostId,
    required this.peopleCount,
    required this.capacity,
  });
}
