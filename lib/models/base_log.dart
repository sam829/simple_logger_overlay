/// Abstract base class for all log entries in the logging system.
///
/// This class defines the common structure and behavior for all log entries.
/// All specific log types (e.g., [SimpleLog], [NetworkLog]) should extend this class.
///
/// Properties:
/// - [timestamp]: When the log entry was created
/// - [tag]: A string identifier for categorizing or filtering logs
///
/// Implementations must override [toJson()] to provide serialization logic.
///
/// Example:
/// ```dart
/// class CustomLog extends BaseLog {
///   final String message;
///
///   CustomLog({
///     required DateTime timestamp,
///     required String tag,
///     required this.message,
///   }) : super(timestamp: timestamp, tag: tag);
///
///   @override
///   Map<String, dynamic> toJson() => {
///     'timestamp': timestamp.toIso8601String(),
///     'tag': tag,
///     'message': message,
///     'type': 'custom',
///   };
/// }
/// ```
abstract class BaseLog {
  /// The exact date and time when the log entry was created.
  ///
  /// This is typically set to `DateTime.now()` when creating a log entry.
  final DateTime timestamp;

  /// A string identifier used to categorize or filter logs.
  ///
  /// Common tags include 'NETWORK', 'ERROR', 'DEBUG', etc. This helps in
  /// filtering and searching through logs based on categories.
  final String tag;

  /// Creates a new [BaseLog] instance.
  ///
  /// Both [timestamp] and [tag] are required parameters as they are
  /// fundamental to all log entries.
  const BaseLog({
    required this.timestamp,
    required this.tag,
  });

  /// Converts the log entry to a JSON-serializable map.
  ///
  /// This method must be implemented by all subclasses to provide
  /// proper serialization of the log data. The implementation should
  /// include all relevant fields from the subclass as well as the
  /// base [timestamp] and [tag] fields.
  ///
  /// Returns:
  /// A `Map<String, dynamic>` containing the log data in a format
  /// that can be serialized to JSON.
  Map<String, dynamic> toJson();
}
