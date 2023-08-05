import 'dart:convert';
import 'package:ringoflutter/Classes/PhotoClasses.dart';
import 'package:ringoflutter/Classes/CoordinatesClass.dart';
import 'package:ringoflutter/Classes/CategoryClass.dart';
import 'package:ringoflutter/Classes/CurrencyClass.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';
import 'package:ringoflutter/Classes/OrganisationClass.dart';

class EventInFeed {
  int? id;
  String name;
  String? description;
  bool isActive;
  String? address;
  Coordinates? coordinates;
  int? mainPhotoId;
  int? distance;
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
    this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.address,
    this.coordinates,
    this.mainPhotoId,
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

  factory EventInFeed.fromJson(Map<String, dynamic> json) {
    List<Category>? categories;
    if (json['categories'] != null) {
      categories = List<Category>.from(
          json['categories'].map((x) => Category.fromJson(x)));
    }

    return EventInFeed(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      address: json['address'],
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
      mainPhotoId: json['mainPhotoId'],
      distance: json['distance'],
      isTicketNeeded: json['isTicketNeeded'],
      price: json['price'],
      currency: json['currency'] != null
          ? Currency.fromJson(json['currency'])
          : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      categories: categories,
      hostId: json['hostId'],
      peopleCount: json['peopleCount'],
      capacity: json['capacity'],
    );
  }
}



class EventFull {
  int id;
  String name;
  String? description;
  bool isActive;
  MainPhoto mainPhoto;
  List<Photo> photos;
  String? address;
  Coordinates? coordinates;
  bool isTicketNeeded;
  double? price;
  Currency? currency;
  String? startTime;
  String? endTime;
  List<Category>? categories;
  Organisation host;
  int peopleCount;
  int capacity;
  bool isSaved;
  bool isRegistered;
  RegistrationForm? registrationForm;

  EventFull({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.mainPhoto,
    required this.photos,
    this.address,
    this.coordinates,
    required this.isTicketNeeded,
    this.price,
    this.currency,
    this.startTime,
    this.endTime,
    this.categories,
    required this.host,
    required this.peopleCount,
    required this.capacity,
    required this.isSaved,
    required this.isRegistered,
    this.registrationForm,
  });

  factory EventFull.fromJson(Map<String, dynamic> json) {
    return EventFull(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      mainPhoto: MainPhoto.fromJson(json['mainPhoto']),
      photos: [],
      address: json['address'],
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
      isTicketNeeded: json['isTicketNeeded'],
      price: json['price'],
      currency: json['currency'] != null
          ? Currency.fromJson(json['currency'])
          : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      categories: json['categories'] != null
          ? List<Category>.from(
          json['categories'].map((x) => Category.fromJson(x)))
          : null,
      host: Organisation.fromJson(json['host']),
      peopleCount: json['peopleCount'],
      capacity: json['capacity'],
      isSaved: json['isSaved'],
      isRegistered: json['isRegistered'],
      registrationForm: json['registrationForm'] != null
          ? RegistrationForm.fromJson(json['registrationForm'])
          : null,
    );
  }
}
