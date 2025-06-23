import 'package:intl/intl.dart';

String parseAndFormatTimestamp(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return formatTimestamp(dateTime);
}

String formatTimestamp(DateTime dateTime) {
  return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
}
