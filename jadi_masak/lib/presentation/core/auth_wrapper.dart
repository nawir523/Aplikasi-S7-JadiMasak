import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jadi_masak/presentation/auth/login_page.dart';
import 'package:jadi_masak/presentation/core/main_navigation_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan StreamBuilder untuk mendengarkan status login
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 1. Jika masih loading (mengecek status)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Tampilkan loading
            ),
          );
        }

        // 2. Jika snapshot punya data (artinya user SUDAH login)
        if (snapshot.hasData) {
          return const MainNavigationPage(); // Arahkan ke Halaman Beranda
        }

        // 3. Jika snapshot tidak punya data (artinya user BELUM login)
        return const LoginPage(); // Arahkan ke Halaman Login
      },
    );
  }
}