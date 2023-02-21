import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 3)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String time;

  TodoModel({required this.name, required this.time});

  factory TodoModel.fromJson(Map data) {
    return TodoModel(name: data["name"], time: data["time"]);
  }

  Map<String,dynamic> toJson() {
    return {"name": name, "time": time};
  }
}
