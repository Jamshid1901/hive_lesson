import 'package:hive_flutter/hive_flutter.dart';

part 'person_model.g.dart';

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String gender;
  @HiveField(2)
  final int count;

  Person({required this.name, required this.count, required this.gender});

  factory Person.fromJson(Map data) {
    return Person(
        name: data["name"], count: data["count"], gender: data["gender"]);
  }
}
