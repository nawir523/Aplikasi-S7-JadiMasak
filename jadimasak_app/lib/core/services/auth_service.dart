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
      // 1. Buat akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan data tambahan ke Firestore (Sesuai ERD Section 3)
      String uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'displayName': name,
        'subscription_status': 'free', // Default status
        'created_at': FieldValue.serverTimestamp(),
      });

      // 3. Update Display Name di Auth profile juga (untuk kemudahan)
      await userCredential.user!.updateDisplayName(name);
      
    } on FirebaseAuthException catch (e) {
      // Melempar error agar bisa ditangkap UI
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

  // Helper: Menerjemahkan kode error Firebase ke Bahasa Indonesia
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