import 'package:uuid/uuid.dart';

class Password {
  final String id;
  final String serviceName;
  final String accountEmail;
  final String secretKey;

  Password({
    String? id,
    required this.serviceName,
    required this.accountEmail,
    required this.secretKey,
  }) : id = id ?? const Uuid().v4();

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      id: json['\$id'] ?? json['id'],
      serviceName: json['serviceName'] ?? '',
      accountEmail: json['accountEmail'] ?? '',
      secretKey: json['secretKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'accountEmail': accountEmail,
      'secretKey': secretKey,
    };
  }

  Password copyWith({
    String? id,
    String? serviceName,
    String? accountEmail,
    String? secretKey,
  }) {
    return Password(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      accountEmail: accountEmail ?? this.accountEmail,
      secretKey: secretKey ?? this.secretKey,
    );
  }
}
