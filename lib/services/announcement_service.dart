import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final _col = FirebaseFirestore.instance.collection('announcements');

  /// Live feed for one location, pinned posts first, newest first.
  Stream<List<Announcement>> streamForLocation(String locationId) {
    return _col
        .where('locationId', isEqualTo: locationId)
        .orderBy('pinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Announcement.fromMap(d.id, d.data())).toList());
  }

  Future<void> post({
    required String locationId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String body,
    bool pinned = false,
    String priority = 'normal',
    bool requireAcknowledgment = false,
  }) {
    return _col.add({
      'locationId': locationId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'title': title,
      'body': body,
      'createdAt': DateTime.now(),
      'pinned': pinned,
      'priority': priority,
      'requireAcknowledgment': requireAcknowledgment,
      'readBy': <String>[],
      'acknowledgedBy': <String>[],
    });
  }

  Future<void> acknowledge(String announcementId, String uid) {
    return _col.doc(announcementId).update({
      'acknowledgedBy': FieldValue.arrayUnion([uid]),
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> markRead(String announcementId, String uid) {
    return _col.doc(announcementId).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> delete(String announcementId) {
    return _col.doc(announcementId).delete();
  }
}
