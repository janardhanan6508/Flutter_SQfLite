class FruitClass {
  final int? id;
  final String name;

  FruitClass({this.id, required this.name});

  factory FruitClass.fromMap(Map<String, dynamic> json) =>
      FruitClass(id: json['id'], name: json['name']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
