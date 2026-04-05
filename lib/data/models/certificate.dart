import 'package:uuid/uuid.dart';

class Certificate {
  final String id;
  final String title;
  final String platform;
  final String date;
  final String issueDate;
  final String? folio;
  final String? credlyId;
  final String? credlyIssuer;
  final String? score;
  final String? notes;
  final String? pdfUrl;

  Certificate({
    String? id,
    required this.title,
    this.platform = 'Otro',
    this.date = '',
    this.issueDate = '',
    this.folio,
    this.credlyId,
    this.credlyIssuer,
    this.score,
    this.notes,
    this.pdfUrl,
  }) : id = id ?? const Uuid().v4();

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['\$id'] ?? json['id'],
      title: json['title'] ?? '',
      platform: json['platform'] ?? 'Otro',
      date: json['date'] ?? '',
      issueDate: json['issueDate'] ?? '',
      folio: json['folio'],
      credlyId: json['credlyId'],
      credlyIssuer: json['credlyIssuer'],
      score: json['score'],
      notes: json['notes'],
      pdfUrl: json['pdfUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'platform': platform,
      'date': date,
      'issueDate': issueDate,
      'folio': folio,
      'credlyId': credlyId,
      'credlyIssuer': credlyIssuer,
      'score': score,
      'notes': notes,
      'pdfUrl': pdfUrl,
    };
  }

  Certificate copyWith({
    String? id,
    String? title,
    String? platform,
    String? date,
    String? issueDate,
    String? folio,
    String? credlyId,
    String? credlyIssuer,
    String? score,
    String? notes,
    String? pdfUrl,
  }) {
    return Certificate(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      date: date ?? this.date,
      issueDate: issueDate ?? this.issueDate,
      folio: folio ?? this.folio,
      credlyId: credlyId ?? this.credlyId,
      credlyIssuer: credlyIssuer ?? this.credlyIssuer,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}
