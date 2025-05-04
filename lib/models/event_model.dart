import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 2)
class EventModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // birthday, graduation, anniversary, etc.

  @HiveField(3)
  DateTime date;

  EventModel({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
  });

  // Helper method to determine status
  String get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate.isBefore(today)) {
      return 'Past';
    } else if (eventDate.isAtSameMomentAs(today)) {
      return 'Current';
    } else {
      return 'Upcoming';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  static EventModel fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      date: DateTime.parse(json['date']),
    );
  }
}
