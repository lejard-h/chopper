import 'package:equatable/equatable.dart';

final class Payload with EquatableMixin {
  const Payload({
    this.statusCode = 200,
    this.message = 'OK',
  });

  final int statusCode;
  final String message;

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        statusCode: json['statusCode'] as int? ?? 200,
        message: json['message'] as String? ?? 'OK',
      );

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'message': message,
      };

  @override
  List<Object?> get props => [
        statusCode,
        message,
      ];
}
