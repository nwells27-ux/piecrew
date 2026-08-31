import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  /// Phase 1 uses one team-wide channel per location, auto-created the
  /// first time someone messages. Returns the channel id.
  Future<String> ensureLocationChannel(String locationId, String locationName) async {
    final channelId = 'loc_$locationId';
    final ref = _db.collection('channels').doc(channelId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(ChatChannel(
        id: channelId,
        locationId: locationId,
        name: '$locationName Team Chat',
      ).toMap());
    }
    return channelId;
  }

  Stream<List<ChatMessage>> streamMessages(String channelId) {
    return _db
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendMessage({
    required String channelId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String text,
  }) {
    return _db
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .add({
      'channelId': channelId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'createdAt': DateTime.now(),
    });
  }
}
