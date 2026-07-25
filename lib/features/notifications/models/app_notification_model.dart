class AppNotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> rawData;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    required this.rawData,
  });

  AppNotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? rawData,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawData: rawData ?? this.rawData,
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      title: _text(json['title'], fallback: 'إشعار جديد'),
      body: _text(json['body']),
      isRead: _toBool(json['is_read'] ?? json['read_at']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase() ?? '';

    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'read';
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  static DateTime? _toDateTime(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }
}
