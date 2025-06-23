import 'base_log.dart';

enum LogLevel { debug, info, error }

class SimpleLog extends BaseLog {
  final String message;
  final LogLevel level;

  SimpleLog({
    required super.timestamp,
    required super.tag,
    required this.message,
    required this.level,
  });

  @override
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'tag': tag,
        'message': message,
        'level': level.name,
        'type': 'simple',
      };

  static SimpleLog fromJson(Map<String, dynamic> json) => SimpleLog(
        timestamp: DateTime.parse(json['timestamp']),
        tag: json['tag'],
        message: json['message'],
        level: LogLevel.values.byName(json['level']),
      );
}
