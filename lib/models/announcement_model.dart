enum AnnouncementPriority { normal, important, urgent }

extension AnnouncementPriorityX on AnnouncementPriority {
  String get label {
    switch (this) {
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.important:
        return 'Important';
      case AnnouncementPriority.urgent:
        return 'Urgent';
    }
  }

  static AnnouncementPriority fromString(String value) {
    return AnnouncementPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => AnnouncementPriority.normal,
    );
  }
}

class Announcement {
  final String id;
  final String locationId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool pinned;
  final AnnouncementPriority priority;
  final bool requireAcknowledgment;
  final List<String> readBy;
  final List<String> acknowledgedBy;

  Announcement({
    required this.id,
    required this.locationId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.body,
    required this.createdAt,
    this.pinned = false,
    this.priority = AnnouncementPriority.normal,
    this.requireAcknowledgment = false,
    this.readBy = const [],
    this.acknowledgedBy = const [],
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      locationId: map['locationId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      pinned: map['pinned'] ?? false,
      priority: AnnouncementPriorityX.fromString(map['priority'] ?? 'normal'),
      requireAcknowledgment: map['requireAcknowledgment'] ?? false,
      readBy: List<String>.from(map['readBy'] ?? []),
      acknowledgedBy: List<String>.from(map['acknowledgedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'title': title,
      'body': body,
      'createdAt': createdAt,
      'pinned': pinned,
      'priority': priority.name,
      'requireAcknowledgment': requireAcknowledgment,
      'readBy': readBy,
      'acknowledgedBy': acknowledgedBy,
    };
  }
}
