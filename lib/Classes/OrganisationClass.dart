import 'dart:convert';

class Organisation {
  int id;
  String? email;
  String name;
  String username;
  int? profilePictureId;
  bool isActive;
  String description;
  double? rating;
  String contacts;
  int? pastEventsCount;
  int? upcomingEventsCount;

  Organisation({
    required this.id,
    this.email,
    required this.name,
    required this.username,
    this.profilePictureId,
    required this.isActive,
    required this.description,
    this.rating,
    required this.contacts,
    this.pastEventsCount,
    this.upcomingEventsCount,
  });

  static Organisation fromJson(Map<String, dynamic> json) {
    return Organisation(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      username: json['username'],
      profilePictureId: json['profilePictureId'],
      isActive: json['isActive'],
      description: json['description'],
      rating: json['rating'],
      contacts: json['contacts'],
      pastEventsCount: json['pastEventsCount'],
      upcomingEventsCount: json['upcomingEventsCount'],
    );
  }
}
