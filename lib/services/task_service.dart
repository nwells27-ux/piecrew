import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final _col = FirebaseFirestore.instance.collection('tasks');

  Stream<List<PieCrewTask>> streamForLocation(String locationId) {
    return _col
        .where('locationId', isEqualTo: locationId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PieCrewTask.fromMap(d.id, d.data())).toList());
  }

  Future<void> create({
    required String locationId,
    required String title,
    String? description,
    required TaskRecurrence recurrence,
    required bool requireNote,
    required String createdBy,
    required String createdByName,
  }) {
    return _col.add({
      'locationId': locationId,
      'title': title,
      'description': description,
      'recurrence': recurrence.name,
      'requireNote': requireNote,
      'active': true,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> deactivate(String taskId) {
    return _col.doc(taskId).update({'active': false});
  }

  /// Live stream of the completion doc for a task's *current* period
  /// (today, for daily tasks; this week, for weekly; ever, for one-time).
  Stream<TaskCompletion?> streamCurrentCompletion(PieCrewTask task) {
    final key = currentPeriodKey(task.recurrence, task.id);
    return _col.doc(task.id).collection('completions').doc(key).snapshots().map(
      (doc) => doc.exists ? TaskCompletion.fromMap(doc.id, doc.data()!) : null,
    );
  }

  Future<void> complete({
    required PieCrewTask task,
    required String uid,
    required String userName,
    String? note,
  }) {
    final key = currentPeriodKey(task.recurrence, task.id);
    return _col.doc(task.id).collection('completions').doc(key).set({
      'completedBy': uid,
      'completedByName': userName,
      'completedAt': DateTime.now(),
      'note': note,
    });
  }
}
