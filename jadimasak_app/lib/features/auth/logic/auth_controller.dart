import 'package:flutter/foundation.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter_riverpod/legacy.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../../core/services/auth_service.dart';

// 1. Provider untuk AuthService (agar bisa dipanggil di mana saja)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 2. State untuk menampung status loading/error
final authStateProvider = StateProvider<bool>((ref) => false); // false = tidak loading

// 3. Controller Class (Logic utama yang dipanggil UI)
class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required Function() onSuccess, // Callback jika berhasil
    required Function(String) onError, // Callback jika gagal
  }) async {
    // Set loading = true (tombol jadi muter-muter)
    ref.read(authStateProvider.notifier).state = true;

    try {
      await ref.read(authServiceProvider).register(
        email: email,
        password: password,
        name: name,
      );
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      // Set loading = false (selesai)
      ref.read(authStateProvider.notifier).state = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    ref.read(authStateProvider.notifier).state = true;
    try {
      await ref.read(authServiceProvider).login(email: email, password: password);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      ref.read(authStateProvider.notifier).state = false;
    }
  }
}

// 4. Provider untuk Controller
final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));

// --- FITUR BARU: FREEMIUM (Langganan Pro) ---

// PROVIDER: Memantau Status Langganan User (Real-time)
// Mengembalikan true jika PRO, false jika FREE
final userSubscriptionProvider = StreamProvider<bool>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(false); // Kalau belum login, anggap free

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        final data = snapshot.data();
        if (data == null) return false;
        // Cek field 'subscription_status' apakah isinya 'pro'
        return data['subscription_status'] == 'pro';
      });
});

// FUNGSI: Upgrade ke Pro (Simulasi)
final upgradeProProvider = Provider((ref) {
  return (VoidCallback onSuccess, Function(String) onError) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'subscription_status': 'pro',
          'pro_since': FieldValue.serverTimestamp(),
        });
        onSuccess();
      } else {
        onError("User tidak ditemukan");
      }
    } catch (e) {
      onError("Gagal upgrade: $e");
    }
  };
});