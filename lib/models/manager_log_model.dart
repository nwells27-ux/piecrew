/// A single manager's end-of-shift log entry. Free-text sections mirror
/// what a GM would actually jot down closing out the day, so the next
/// manager (and above-store leadership) can catch up in a minute.
class ManagerLogEntry {
  final String id;
  final String locationId;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String? salesNotes;
  final String? staffingNotes;
  final String? customerNotes;
  final String? equipmentNotes;
  final String? generalNotes;

  ManagerLogEntry({
    required this.id,
    required this.locationId,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.salesNotes,
    this.staffingNotes,
    this.customerNotes,
    this.equipmentNotes,
    this.generalNotes,
  });

  bool get isEmpty =>
      (salesNotes == null || salesNotes!.isEmpty) &&
      (staffingNotes == null || staffingNotes!.isEmpty) &&
      (customerNotes == null || customerNotes!.isEmpty) &&
      (equipmentNotes == null || equipmentNotes!.isEmpty) &&
      (generalNotes == null || generalNotes!.isEmpty);

  factory ManagerLogEntry.fromMap(String id, Map<String, dynamic> map) {
    return ManagerLogEntry(
      id: id,
      locationId: map['locationId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      salesNotes: map['salesNotes'],
      staffingNotes: map['staffingNotes'],
      customerNotes: map['customerNotes'],
      equipmentNotes: map['equipmentNotes'],
      generalNotes: map['generalNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'salesNotes': salesNotes,
      'staffingNotes': staffingNotes,
      'customerNotes': customerNotes,
      'equipmentNotes': equipmentNotes,
      'generalNotes': generalNotes,
    };
  }
}
