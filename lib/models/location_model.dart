class PieCrewLocation {
  final String id;
  final String name;
  final String address;
  final bool isPilot;

  PieCrewLocation({
    required this.id,
    required this.name,
    required this.address,
    this.isPilot = false,
  });

  factory PieCrewLocation.fromMap(String id, Map<String, dynamic> map) {
    return PieCrewLocation(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      isPilot: map['isPilot'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'isPilot': isPilot,
    };
  }
}

/// Seed data for your five locations. Mark the pilot location's `isPilot`
/// as true — PieCrew Phase 1 only activates messaging/announcements for
/// that location until you're ready to roll out to the rest.
const List<Map<String, dynamic>> seedLocations = [
  {'id': 'covington', 'name': 'Your Pie - Covington', 'isPilot': false},
  {'id': 'snellville', 'name': 'Your Pie - Snellville', 'isPilot': false},
  {'id': 'winder-bethlehem', 'name': 'Your Pie - Winder/Bethlehem', 'isPilot': false},
  {'id': 'loganville', 'name': 'Your Pie - Loganville', 'isPilot': false},
  {'id': 'monroe', 'name': 'Your Pie - Monroe', 'isPilot': false},
];
