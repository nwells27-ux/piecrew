import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manager_log_model.dart';

class ManagerLogService {
  final _col = FirebaseFirestore.instance.collection('manager_logs');

  Stream<List<ManagerLogEntry>> streamForLocation(String locationId, {int limit = 30}) {
    return _col
        .where('locationId', isEqualTo: locationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ManagerLogEntry.fromMap(d.id, d.data())).toList());
  }

  Future<void> post({
    required String locationId,
    required String authorId,
    required String authorName,
    String? salesNotes,
    String? staffingNotes,
    String? customerNotes,
    String? equipmentNotes,
    String? generalNotes,
  }) {
    return _col.add({
      'locationId': locationId,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': DateTime.now(),
      'salesNotes': salesNotes,
      'staffingNotes': staffingNotes,
      'customerNotes': customerNotes,
      'equipmentNotes': equipmentNotes,
      'generalNotes': generalNotes,
    });
  }
}
