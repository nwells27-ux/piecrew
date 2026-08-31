enum IssuePriority { normal, urgent }

extension IssuePriorityX on IssuePriority {
  String get label => this == IssuePriority.urgent ? 'Urgent' : 'Normal';
  static IssuePriority fromString(String value) =>
      value == 'urgent' ? IssuePriority.urgent : IssuePriority.normal;
}

enum IssueStatus { reported, reviewing, vendorContacted, repairScheduled, resolved }

extension IssueStatusX on IssueStatus {
  String get label {
    switch (this) {
      case IssueStatus.reported:
        return 'Reported';
      case IssueStatus.reviewing:
        return 'Manager Reviewing';
      case IssueStatus.vendorContacted:
        return 'Vendor Contacted';
      case IssueStatus.repairScheduled:
        return 'Repair Scheduled';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }

  static IssueStatus fromString(String value) {
    return IssueStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => IssueStatus.reported,
    );
  }
}

class MaintenanceIssue {
  final String id;
  final String locationId;
  final String equipmentName;
  final String description;
  final IssuePriority priority;
  final IssueStatus status;
  final String reportedBy;
  final String reportedByName;
  final DateTime reportedAt;
  final String? lastUpdatedByName;
  final DateTime? lastUpdatedAt;

  MaintenanceIssue({
    required this.id,
    required this.locationId,
    required this.equipmentName,
    required this.description,
    this.priority = IssuePriority.normal,
    this.status = IssueStatus.reported,
    required this.reportedBy,
    required this.reportedByName,
    required this.reportedAt,
    this.lastUpdatedByName,
    this.lastUpdatedAt,
  });

  factory MaintenanceIssue.fromMap(String id, Map<String, dynamic> map) {
    return MaintenanceIssue(
      id: id,
      locationId: map['locationId'] ?? '',
      equipmentName: map['equipmentName'] ?? '',
      description: map['description'] ?? '',
      priority: IssuePriorityX.fromString(map['priority'] ?? 'normal'),
      status: IssueStatusX.fromString(map['status'] ?? 'reported'),
      reportedBy: map['reportedBy'] ?? '',
      reportedByName: map['reportedByName'] ?? '',
      reportedAt: map['reportedAt']?.toDate() ?? DateTime.now(),
      lastUpdatedByName: map['lastUpdatedByName'],
      lastUpdatedAt: map['lastUpdatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'equipmentName': equipmentName,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'reportedAt': reportedAt,
      'lastUpdatedByName': lastUpdatedByName,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }
}
