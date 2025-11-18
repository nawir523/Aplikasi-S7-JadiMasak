import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 1. Tahan sebentar (misal 2 detik) agar logo terlihat (Branding)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Cek apakah ada user yang sedang login di memori HP
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // JIKA SUDAH LOGIN -> Ke Home
      context.go('/home');
    } else {
      // JIKA BELUM -> Ke Login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Latar oranye biar segar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Gunakan gambar asetmu, atau icon sementara)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
                // Jika gambar logo gagal dimuat, pakai Icon ini:
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.restaurant_menu, size: 80, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Jadi Masak",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator putih kecil
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}