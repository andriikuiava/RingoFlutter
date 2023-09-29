class ContactCard {
  int id;
  int? ordinal;
  String title;
  String content;

  ContactCard({
    required this.id,
    this.ordinal,
    required this.title,
    required this.content,
  });

  static ContactCard fromJson(Map<String, dynamic> json) {
    return ContactCard(
      id: json['id'],
      ordinal: json['ordinal'],
      title: json['title'],
      content: json['content'],
    );
  }
}
