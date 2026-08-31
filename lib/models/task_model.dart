enum TaskRecurrence { once, daily, weekly }

extension TaskRecurrenceX on TaskRecurrence {
  String get label {
    switch (this) {
      case TaskRecurrence.once:
        return 'One-time';
      case TaskRecurrence.daily:
        return 'Daily';
      case TaskRecurrence.weekly:
        return 'Weekly';
    }
  }

  static TaskRecurrence fromString(String value) {
    return TaskRecurrence.values.firstWhere(
      (r) => r.name == value,
      orElse: () => TaskRecurrence.once,
    );
  }
}

/// A task or checklist item. Recurring tasks don't store a single
/// "completed" flag — completion is tracked per period in a
/// `tasks/{id}/completions` subcollection (keyed by date), so a daily
/// task automatically shows as "not done" again the next day while
/// keeping a full history of who completed it and when.
class PieCrewTask {
  final String id;
  final String locationId;
  final String title;
  final String? description;
  final TaskRecurrence recurrence;
  final bool requireNote;
  final bool active;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;

  PieCrewTask({
    required this.id,
    required this.locationId,
    required this.title,
    this.description,
    this.recurrence = TaskRecurrence.once,
    this.requireNote = false,
    this.active = true,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  factory PieCrewTask.fromMap(String id, Map<String, dynamic> map) {
    return PieCrewTask(
      id: id,
      locationId: map['locationId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      recurrence: TaskRecurrenceX.fromString(map['recurrence'] ?? 'once'),
      requireNote: map['requireNote'] ?? false,
      active: map['active'] ?? true,
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'title': title,
      'description': description,
      'recurrence': recurrence.name,
      'requireNote': requireNote,
      'active': active,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt,
    };
  }
}

class TaskCompletion {
  final String id; // date key, e.g. 2026-08-30, or the task id for one-time tasks
  final String completedBy;
  final String completedByName;
  final DateTime completedAt;
  final String? note;

  TaskCompletion({
    required this.id,
    required this.completedBy,
    required this.completedByName,
    required this.completedAt,
    this.note,
  });

  factory TaskCompletion.fromMap(String id, Map<String, dynamic> map) {
    return TaskCompletion(
      id: id,
      completedBy: map['completedBy'] ?? '',
      completedByName: map['completedByName'] ?? '',
      completedAt: map['completedAt']?.toDate() ?? DateTime.now(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedBy': completedBy,
      'completedByName': completedByName,
      'completedAt': completedAt,
      'note': note,
    };
  }
}

/// Returns the key used for today's (or this task's) completion document:
/// one-time tasks always use the task's own id; daily tasks use the date;
/// weekly tasks use the ISO year-week.
String currentPeriodKey(TaskRecurrence recurrence, String taskId) {
  final now = DateTime.now();
  switch (recurrence) {
    case TaskRecurrence.once:
      return taskId;
    case TaskRecurrence.daily:
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    case TaskRecurrence.weekly:
      final firstDayOfYear = DateTime(now.year, 1, 1);
      final daysSinceStart = now.difference(firstDayOfYear).inDays;
      final week = ((daysSinceStart + firstDayOfYear.weekday - 1) / 7).floor();
      return '${now.year}-W$week';
  }
}
