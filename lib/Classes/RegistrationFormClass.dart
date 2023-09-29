class RegistrationForm {
  String title;
  String? description;
  List<Question> questions;

  RegistrationForm({
    required this.title,
    this.description,
    required this.questions,
  });

  factory RegistrationForm.fromJson(Map<String, dynamic> json) {
    return RegistrationForm(
      title: json['title'],
      description: json['description'],
      questions: List<Question>.from(
        json['questions'].map((question) => Question.fromJson(question)),
      ),
    );
  }
}

class Question {
  int id;
  String content;
  bool required;
  bool? multipleOptionsAllowed;
  String type;
  int? maxCharacters;
  List<Option>? options;

  Question({
    required this.id,
    required this.content,
    required this.required,
    required this.multipleOptionsAllowed,
    required this.type,
    required this.maxCharacters,
    this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      content: json['content'],
      required: json['required'],
      multipleOptionsAllowed: json['multipleOptionsAllowed'],
      type: json['type'],
      maxCharacters: json['maxCharacters'],
      options: json['options'] != null
          ? List<Option>.from(
              json['options'].map((option) => Option.fromJson(option)),
            )
          : null,
    );
  }
}

class Option {
  int id;
  String content;

  Option({
    required this.id,
    required this.content,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      content: json['content'],
    );
  }
}
