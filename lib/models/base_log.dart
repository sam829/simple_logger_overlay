abstract class BaseLog {
  final DateTime timestamp;
  final String tag;

  BaseLog({required this.timestamp, required this.tag});

  Map<String, dynamic> toJson();
}
