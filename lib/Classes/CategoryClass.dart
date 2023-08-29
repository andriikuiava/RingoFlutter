class CategoryClass {
  int id;
  String name;

  CategoryClass({
    required this.id,
    required this.name,
  });

  factory CategoryClass.fromJson(Map<String, dynamic> json) {
    return CategoryClass(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return 'CategoryClass{id: $id, name: $name}';
  }
}
