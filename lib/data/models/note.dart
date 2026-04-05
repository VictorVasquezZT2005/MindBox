class Note {
  final String id;
  final String userId;
  final String content;
  final String type;
  final int timestamp;

  Note({
    required this.id,
    required this.userId,
    required this.content,
    this.type = 'Personal',
    required this.timestamp,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['\$id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'Personal',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'type': type,
      'timestamp': timestamp,
    };
  }

  Note copyWith({
    String? id,
    String? userId,
    String? content,
    String? type,
    int? timestamp,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
