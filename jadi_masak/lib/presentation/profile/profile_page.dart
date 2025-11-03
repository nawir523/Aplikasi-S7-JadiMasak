import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Fungsi Logout (RF-AUTH-04)
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // AuthWrapper akan otomatis mendeteksi ini dan pindah ke LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _logout, // Panggil fungsi logout
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Keluar'),
        ),
      ),
    );
  }
}