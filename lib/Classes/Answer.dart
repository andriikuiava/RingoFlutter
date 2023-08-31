class Answer {
  int questionId;
  String? content;
  List<int>? optionIds;

  Answer({
    required this.questionId,
    this.content,
    this.optionIds,
  });

  Map<String, dynamic> toJson() {
    if (content != null) {
      return {
        'questionId': questionId,
        'content': content,
      };
    } else if (optionIds != null) {
      return {
        'questionId': questionId,
        'optionIds': optionIds,
      };
    } else {
      return {
        'questionId': questionId,
      };
    }
  }

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'],
      content: json['content'],
      optionIds: json['optionIds'] != null ? List<int>.from(json['optionIds']) : null,
    );
  }
}
