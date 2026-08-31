enum UserRole { owner, manager, staff }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.staff,
    );
  }
}

class PieCrewUser {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String locationId;
  final UserRole role;
  final String? fcmToken;
  final DateTime createdAt;

  PieCrewUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.locationId,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  factory PieCrewUser.fromMap(String uid, Map<String, dynamic> map) {
    return PieCrewUser(
      uid: uid,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      locationId: map['locationId'] ?? '',
      role: UserRoleX.fromString(map['role'] ?? 'staff'),
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'locationId': locationId,
      'role': role.name,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
    };
  }

  bool get canPostAnnouncements =>
      role == UserRole.owner || role == UserRole.manager;
}
