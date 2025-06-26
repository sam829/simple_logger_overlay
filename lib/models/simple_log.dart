import 'base_log.dart';

/// Represents the severity level of a log message.
///
/// Levels are ordered by increasing severity:
/// - [debug]: Fine-grained informational events for debugging purposes
/// - [info]: General informational messages about application progress
/// - [error]: Error events that might still allow the application to continue
enum LogLevel { debug, info, error }

/// A simple log entry representing a basic logging event.
///
/// This class extends [BaseLog] to provide a simple logging structure
/// that includes a message and a severity level. It's typically used
/// for general application logging through `LoggerController.log()`.
///
/// Example usage:
/// ```dart
/// final log = SimpleLog(
///   timestamp: DateTime.now(),
///   tag: 'AUTH',
///   message: 'User logged in successfully',
///   level: LogLevel.info,
/// );
/// ```
class SimpleLog extends BaseLog {
  /// The main content of the log message.
  ///
  /// This should be a human-readable description of the event being logged.
  /// For consistency, it's recommended to:
  /// - Start with a capital letter
  /// - End without a period
  /// - Be concise but descriptive
  final String message;

  /// The severity level of the log entry.
  ///
  /// This determines both the visual representation in logs and can be used
  /// for filtering log messages by severity. See [LogLevel] for available levels.
  final LogLevel level;

  /// Creates a new [SimpleLog] instance.
  ///
  /// All parameters are required:
  /// - [timestamp]: When the event occurred
  /// - [tag]: Category or component identifier (e.g., 'AUTH', 'NETWORK', 'UI')
  /// - [message]: The log message content
  /// - [level]: The severity level of the log entry
  const SimpleLog({
    required super.timestamp,
    required super.tag,
    required this.message,
    required this.level,
  });

  /// Converts the log entry to a JSON-serializable map.
  ///
  /// The resulting map includes all fields from [BaseLog] plus the [message],
  /// [level], and a 'type' field set to 'simple' for identification.
  ///
  /// Returns:
  /// A `Map<String, dynamic>` containing:
  /// - timestamp: ISO 8601 formatted timestamp
  /// - tag: The log category/component
  /// - message: The log message
  /// - level: The log level name ('debug', 'info', or 'error')
  /// - type: Always 'simple' to identify this log type
  @override
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'tag': tag,
        'message': message,
        'level': level.name,
        'type': 'simple',
      };

  /// Creates a [SimpleLog] instance from a JSON map.
  ///
  /// This is the inverse of [toJson()] and is typically used when deserializing
  /// log entries from storage. The input map should contain all fields returned
  /// by [toJson()].
  ///
  /// Parameters:
  /// - json: A map containing the serialized log data
  ///
  /// Returns:
  /// A new [SimpleLog] instance with the deserialized data
  ///
  /// Throws:
  /// - FormatException: If the timestamp is not in ISO 8601 format
  /// - ArgumentError: If the level is not a valid [LogLevel] name
  static SimpleLog fromJson(Map<String, dynamic> json) => SimpleLog(
        timestamp: DateTime.parse(json['timestamp'] as String),
        tag: json['tag'] as String,
        message: json['message'] as String,
        level: LogLevel.values.byName(json['level'] as String),
      );
}
