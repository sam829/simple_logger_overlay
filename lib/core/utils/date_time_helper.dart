import 'package:intl/intl.dart';

/// Helper function to parse a string timestamp to human readable format
/// i.e. 2025-06-05T12:33:32 will be readable as 5th June 2025, 12:33 PM
///
/// [timestamp] - String timestamp in ISO 8601 format
///
/// Returns a human readable string in the format of `5th June 2025, 12:33 PM`
String parseAndFormatTimestamp(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return formatTimestamp(dateTime);
}

/// Helper function to format a DateTime object to human readable format
/// i.e. 2025-06-05T12:33:32 will be readable as 5th June 2025, 12:33 PM
///
/// [dateTime] - DateTime object
///
/// Returns a human readable string in the format of `5th June 2025, 12:33 PM`
String formatTimestamp(DateTime dateTime) {
  return DateFormat('dd MMM yyyy, hh:mm:ssss a').format(dateTime);
}

/// Get the current timestamp in UTC format.
///
/// Returns a string in the format of `yyyy-MM-ddTHH:mm:ss.SSS'Z'`.
String get getCurrentTimestampUTC => formatTimestampForUTC(DateTime.now());

/// Format a DateTime object to a string in UTC format.
///
/// [dateTime] - DateTime object
///
/// Returns a string in the format of `yyyy-MM-ddTHH:mm:ss.SSS'Z'`.
String formatTimestampForUTC(DateTime dateTime) {
  return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS\'Z\'').format(dateTime);
}

/// Get the current timestamp in the local timezone format.
///
/// Returns a string in the format of `yyyy-MM-ddTHH:mm:ss.SSSZ`.
String get getCurrentTimestampWithOffset =>
    formatTimestampForWithOffset(DateTime.now());

/// Format a DateTime object to a string in the local timezone format.
///
/// [dateTime] - DateTime object
///
/// Returns a string in the format of `yyyy-MM-ddTHH:mm:ss.SSSZ`.
String formatTimestampForWithOffset(DateTime dateTime) {
  return DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(dateTime);
}
