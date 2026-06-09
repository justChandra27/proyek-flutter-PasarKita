// lib/core/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // REGISTER
  // =========================

  Future<String?> register({
    required String fullName,
    required String username,
    required String role,
    required String password,
  }) async {
    try {
      final usernameCheck = await _firestore
          .collection('users')
          .where(
            'username',
            isEqualTo: username.toLowerCase().trim(),
          )
          .limit(1)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return 'Username sudah digunakan';
      }

      final email =
          '${username.toLowerCase().trim()}@pasarkita.app';

      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'fullName': fullName.trim(),
        'username': username.toLowerCase().trim(),
        'role': role,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
  print('FIREBASE AUTH ERROR: ${e.code}');
  print('FIREBASE AUTH MESSAGE: ${e.message}');
  return '${e.code} - ${e.message}';
} catch (e) {
  print('REGISTER ERROR: $e');
  return e.toString();
}
  }

  // =========================
  // LOGIN
  // =========================

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _firestore
          .collection('users')
          .where(
            'username',
            isEqualTo: username.toLowerCase().trim(),
          )
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw Exception('Username tidak ditemukan');
      }

      final userData = result.docs.first.data();

      final status = userData['status'];

      if (status == 'pending') {
        throw Exception(
          'Akun Anda sedang menunggu verifikasi admin',
        );
      }

      if (status == 'rejected') {
        throw Exception(
          'Akun Anda ditolak admin',
        );
      }

      final email =
          '${username.toLowerCase().trim()}@pasarkita.app';

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userData;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Login gagal',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // APPROVE USER
  // =========================

  Future<void> approveUser(
    String uid,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'status': 'approved',
      'updatedAt': Timestamp.now(),
    });
  }

  // =========================
  // REJECT USER
  // =========================

  Future<void> rejectUser(
    String uid,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'status': 'rejected',
      'updatedAt': Timestamp.now(),
    });
  }

  // =========================
  // PENDING USERS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getPendingUsers() {
    return _firestore
        .collection('users')
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .snapshots();
  }

  // =========================
  // ALL USERS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // =========================
  // GET USER
  // =========================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getUser(String uid) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .get();
  }

  // =========================
  // CURRENT USER
  // =========================

  User? get currentUser {
    return _auth.currentUser;
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await _auth.signOut();
  }
}
