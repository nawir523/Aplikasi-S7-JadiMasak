import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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