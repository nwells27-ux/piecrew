class ChatMessage {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      channelId: map['channelId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'],
      text: map['text'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'createdAt': createdAt,
    };
  }
}

/// A channel is one location's team-wide chat for Phase 1.
/// (1:1 DMs and multi-channel support are Phase 2.)
class ChatChannel {
  final String id;
  final String locationId;
  final String name;

  ChatChannel({
    required this.id,
    required this.locationId,
    required this.name,
  });

  factory ChatChannel.fromMap(String id, Map<String, dynamic> map) {
    return ChatChannel(
      id: id,
      locationId: map['locationId'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'name': name,
    };
  }
}
