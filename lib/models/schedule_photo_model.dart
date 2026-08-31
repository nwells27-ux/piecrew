/// A photo of the printed/handwritten weekly schedule, uploaded by a
/// manager for the team to see. Only the most recent one per location
/// is shown in the app; older ones stay in Storage/Firestore as history.
class SchedulePhoto {
  final String id;
  final String locationId;
  final String imageUrl;
  final String storagePath;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime uploadedAt;

  SchedulePhoto({
    required this.id,
    required this.locationId,
    required this.imageUrl,
    required this.storagePath,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedAt,
  });

  factory SchedulePhoto.fromMap(String id, Map<String, dynamic> map) {
    return SchedulePhoto(
      id: id,
      locationId: map['locationId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      storagePath: map['storagePath'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedByName: map['uploadedByName'] ?? '',
      uploadedAt: map['uploadedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'uploadedAt': uploadedAt,
    };
  }
}
