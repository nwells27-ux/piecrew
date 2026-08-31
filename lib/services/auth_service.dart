import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<PieCrewUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return PieCrewUser.fromMap(uid, doc.data()!);
  }

  /// Sign in with email/password. Accounts are created by an owner/manager
  /// via inviteStaff() below, not self-signup — keeps the pilot location
  /// roster controlled while you test this out.
  Future<PieCrewUser?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) return null;
    return getUserProfile(cred.user!.uid);
  }

  Future<void> signOut() => _auth.signOut();

  /// Owner/manager creates an account for a new team member.
  Future<PieCrewUser> inviteStaff({
    required String email,
    required String tempPassword,
    required String displayName,
    required String locationId,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: tempPassword,
    );
    final user = PieCrewUser(
      uid: cred.user!.uid,
      displayName: displayName,
      email: email,
      locationId: locationId,
      role: role,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  Future<void> updateFcmToken(String uid, String token) {
    return _db.collection('users').doc(uid).update({'fcmToken': token});
  }
}
