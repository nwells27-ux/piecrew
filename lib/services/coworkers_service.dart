import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class CoworkersService {
  final _col = FirebaseFirestore.instance.collection('users');

  Stream<List<PieCrewUser>> streamForLocation(String locationId) {
    return _col.where('locationId', isEqualTo: locationId).snapshots().map((snap) {
      final users = snap.docs.map((d) => PieCrewUser.fromMap(d.id, d.data())).toList();
      // Owners first, then managers, then staff; alphabetical within each.
      const order = {'owner': 0, 'manager': 1, 'staff': 2};
      users.sort((a, b) {
        final roleCompare = (order[a.role.name] ?? 3).compareTo(order[b.role.name] ?? 3);
        if (roleCompare != 0) return roleCompare;
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });
      return users;
    });
  }
}
