import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// سرویس احراز هویت. پشتیبانی از ورود کاربر عادی و ادمین (Role Based Access)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<UserModel> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      phone: phone,
      role: 'user',
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
    return user;
  }

  /// بررسی نقش ادمین از روی collection مجزای admins طبق Security Rules
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection(AppConstants.adminsCollection).doc(uid).get();
    return doc.exists;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
