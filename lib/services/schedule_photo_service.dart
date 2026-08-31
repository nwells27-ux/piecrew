import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/schedule_photo_model.dart';

class SchedulePhotoService {
  final _col = FirebaseFirestore.instance.collection('schedule_photos');
  final _storage = FirebaseStorage.instance;

  /// Latest photo for a location — deliberately a plain equality filter
  /// with client-side max-by-date rather than an .orderBy(), avoiding a
  /// composite index for a screen this simple.
  Stream<SchedulePhoto?> streamLatestForLocation(String locationId) {
    return _col.where('locationId', isEqualTo: locationId).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      final photos = snap.docs.map((d) => SchedulePhoto.fromMap(d.id, d.data())).toList();
      photos.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return photos.first;
    });
  }

  Future<void> upload({
    required File file,
    required String locationId,
    required String uploadedBy,
    required String uploadedByName,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = 'schedule_photos/$locationId/$fileName';
    final ref = _storage.ref(storagePath);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await _col.add({
      'locationId': locationId,
      'imageUrl': url,
      'storagePath': storagePath,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'uploadedAt': DateTime.now(),
    });
  }
}
