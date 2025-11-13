import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/logic/auth_controller.dart';
import '../../../core/services/seeder_service.dart'; // Import seeder

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Pengguna")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Fitur Profil akan hadir di v1.5"),
            const SizedBox(height: 40),
            
            // --- TOMBOL LOGOUT ---
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authServiceProvider).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const Text("Area Admin (Sementara)", style: TextStyle(color: Colors.grey)),
            
            // --- TOMBOL UPLOAD DATA (Hapus tombol ini nanti kalau mau rilis) ---
            TextButton(
              onPressed: () async {
                // Panggil service upload
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sedang mengupload data...")),
                );
                
                await SeederService().uploadInitialData();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sukses! Cek Firestore Anda.")),
                  );
                }
              },
              child: const Text("Upload Data Resep Awal"),
            ),
          ],
        ),
      ),
    );
  }
}