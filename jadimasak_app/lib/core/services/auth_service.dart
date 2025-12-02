import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan user yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  // Fungsi Register (Daftar)
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'displayName': name,
        'subscription_status': 'free',
        'created_at': FieldValue.serverTimestamp(),
      });

      await userCredential.user!.updateDisplayName(name);
      
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Fungsi Login
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Fungsi Reset Password
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // --- FUNGSI BARU: UPDATE PROFIL ---
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Update data di Auth (User Token)
        if (name != null) await user.updateDisplayName(name);
        if (photoUrl != null) await user.updatePhotoURL(photoUrl);
        
        // 2. Update juga di Firestore (Database User)
        // SetOptions(merge: true) penting agar data lain tidak terhapus
        await _firestore.collection('users').doc(user.uid).set({
          if (name != null) 'displayName': name,
          if (photoUrl != null) 'photoURL': photoUrl,
        }, SetOptions(merge: true)); 
        
        // Reload user agar data terbaru terbaca di aplikasi
        await user.reload(); 
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  // ----------------------------------

  // Helper Error
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return 'Gagal: ${e.message}';
    }
  }
}