import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';

class ShiftService {
  final _col = FirebaseFirestore.instance.collection('shifts');

  /// Deliberately a plain equality filter with client-side sorting rather
  /// than an .orderBy() — avoids requiring a Firestore composite index
  /// for a screen this simple.
  Stream<List<Shift>> streamForLocation(String locationId) {
    return _col.where('locationId', isEqualTo: locationId).snapshots().map((snap) {
      final shifts = snap.docs.map((d) => Shift.fromMap(d.id, d.data())).toList();
      shifts.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.startMinutes.compareTo(b.startMinutes);
      });
      return shifts;
    });
  }

  Future<void> create({
    required String locationId,
    required String employeeName,
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    String? position,
    required String createdBy,
    required String createdByName,
  }) {
    return _col.add({
      'locationId': locationId,
      'employeeName': employeeName,
      'date': DateTime(date.year, date.month, date.day),
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'position': position,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> delete(String shiftId) {
    return _col.doc(shiftId).delete();
  }
}
