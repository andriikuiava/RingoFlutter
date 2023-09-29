import 'package:ringoflutter/Classes/UserClass.dart';

class Review {
  int id;
  User participant;
  String? comment;
  int rate;
  String createdAt;

  Review({
    required this.id,
    required this.participant,
    this.comment,
    required this.rate,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      participant: User.fromJson(json['participant']),
      comment: json['comment'],
      rate: json['rate'],
      createdAt: json['createdAt'],
    );
  }
}

class CreateReview {
  int id;
  String comment;
  int rate;

  CreateReview({
    required this.id,
    required this.comment,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment,
        "rate": rate,
      };
}
