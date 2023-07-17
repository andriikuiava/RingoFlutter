import 'dart:convert';
import 'package:ringoflutter/Classes/PhotoClasses.dart';
import 'package:ringoflutter/Classes/CoordinatesClass.dart';
import 'package:ringoflutter/Classes/CategoryClass.dart';
import 'package:ringoflutter/Classes/CurrencyClass.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';

class Event {
  int id;
  String name;
  String? description;
  bool isActive;
  MainPhoto mainPhoto;
  List<Photo>? photos;
  String? address;
  Coordinates coordinates;
  bool isTicketNeeded;
  double price;
  Currency currency;
  List<Category>? categories;
  Organisation host;
  int? peopleCount;
  int? capacity;
  bool isSaved;
  int peopleSaved;
  bool isRegistered;
  RegistrationForm? registrationForm;
}