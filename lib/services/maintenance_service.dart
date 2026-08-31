import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_model.dart';

class MaintenanceService {
  final _col = FirebaseFirestore.instance.collection('maintenance_issues');

  Stream<List<MaintenanceIssue>> streamForLocation(String locationId) {
    return _col
        .where('locationId', isEqualTo: locationId)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map((d) => MaintenanceIssue.fromMap(d.id, d.data())).toList();
      // Open issues first (newest first within each group), resolved last.
      items.sort((a, b) {
        final aResolved = a.status == IssueStatus.resolved;
        final bResolved = b.status == IssueStatus.resolved;
        if (aResolved != bResolved) return aResolved ? 1 : -1;
        return b.reportedAt.compareTo(a.reportedAt);
      });
      return items;
    });
  }

  Future<void> report({
    required String locationId,
    required String equipmentName,
    required String description,
    required IssuePriority priority,
    required String reportedBy,
    required String reportedByName,
  }) {
    return _col.add({
      'locationId': locationId,
      'equipmentName': equipmentName,
      'description': description,
      'priority': priority.name,
      'status': IssueStatus.reported.name,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'reportedAt': DateTime.now(),
      'lastUpdatedByName': null,
      'lastUpdatedAt': null,
    });
  }

  Future<void> updateStatus({
    required String issueId,
    required IssueStatus status,
    required String updatedByName,
  }) {
    return _col.doc(issueId).update({
      'status': status.name,
      'lastUpdatedByName': updatedByName,
      'lastUpdatedAt': DateTime.now(),
    });
  }
}
