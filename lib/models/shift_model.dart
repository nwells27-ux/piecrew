import 'package:flutter/material.dart';

/// A single scheduled shift at a location. Times are stored as minutes
/// since midnight so they sort naturally without needing a full DateTime,
/// and the date is stored separately (day-only) so a shift always shows
/// on the calendar day it's meant for regardless of time zone quirks.
class Shift {
  final String id;
  final String locationId;
  final String employeeName;
  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final String? position;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;

  Shift({
    required this.id,
    required this.locationId,
    required this.employeeName,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    this.position,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  TimeOfDay get startTime => TimeOfDay(hour: startMinutes ~/ 60, minute: startMinutes % 60);
  TimeOfDay get endTime => TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);

  factory Shift.fromMap(String id, Map<String, dynamic> map) {
    return Shift(
      id: id,
      locationId: map['locationId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      startMinutes: map['startMinutes'] ?? 0,
      endMinutes: map['endMinutes'] ?? 0,
      position: map['position'],
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'employeeName': employeeName,
      'date': date,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'position': position,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt,
    };
  }
}

String formatTimeOfDay(TimeOfDay t) {
  final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}
