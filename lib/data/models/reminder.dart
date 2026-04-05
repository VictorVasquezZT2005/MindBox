import 'package:uuid/uuid.dart';

class Reminder {
  final String id;
  final String title;
  final String notes;
  final String url;
  final String date;
  final String time;
  final bool isUrgent;
  final String listCategory;

  Reminder({
    String? id,
    required this.title,
    this.notes = '',
    this.url = '',
    this.date = '',
    this.time = '',
    this.isUrgent = false,
    this.listCategory = 'Imbox',
  }) : id = id ?? const Uuid().v4();

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['\$id'] ?? json['id'],
      title: json['title'] ?? '',
      notes: json['notes'] ?? '',
      url: json['url'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      isUrgent: json['isUrgent'] ?? false,
      listCategory: json['listCategory'] ?? 'Imbox',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'notes': notes,
      'url': url,
      'date': date,
      'time': time,
      'isUrgent': isUrgent,
      'listCategory': listCategory,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? notes,
    String? url,
    String? date,
    String? time,
    bool? isUrgent,
    String? listCategory,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      url: url ?? this.url,
      date: date ?? this.date,
      time: time ?? this.time,
      isUrgent: isUrgent ?? this.isUrgent,
      listCategory: listCategory ?? this.listCategory,
    );
  }
}
