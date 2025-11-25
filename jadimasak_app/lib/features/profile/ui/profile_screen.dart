import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../../recipes/logic/bookmark_controller.dart';
import '../../../core/services/seeder_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil Data User yang sedang login
    final user = FirebaseAuth.instance.currentUser;
    
    // 2. Ambil Data Statistik (Jumlah Resep Tersimpan)
    final savedRecipesAsync = ref.watch(bookmarkedIdsProvider);
    final savedCount = savedRecipesAsync.value?.length ?? 0;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Tidak ada user login.")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==============================
            // 1. HEADER PROFIL (Oranye)
            // ==============================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Background Oranye
                Container(
                  height: 225,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    
                  ),
                  padding: const EdgeInsets.only(top: 40, bottom: 80), // Ruang untuk konten
                  child: Column(
                    children: [
                      const Text(
                        "Profil Saya",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Kartu Info User (Mengambang)
                Positioned(
                  bottom: -100,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar Foto
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Nama User
                        Text(
                          user.displayName ?? "Pengguna Baru",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.email ?? "-",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        // Statistik
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem("Tersimpan", savedCount.toString()),
                            _buildStatItem("Status", "Gratis"), // Bisa diganti Pro nanti
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Spasi untuk kartu yang mengambang
            const SizedBox(height: 120),

            // ==============================
            // 2. MENU OPSI
            // ==============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.edit_outlined,
                    title: "Edit Profil",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur Edit Profil segera hadir di v1.5!")),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: "Tentang Aplikasi",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Jadi Masak",
                        applicationVersion: "1.0.0",
                        applicationIcon: const Icon(Icons.restaurant_menu, size: 50, color: AppColors.primary),
                        children: [
                          const Text("Aplikasi resep anti-mubazir untuk membantu kamu memasak dengan bahan yang ada."),
                        ],
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.logout,
                    title: "Keluar (Logout)",
                    isDestructive: true,
                    onTap: () async {
                      await ref.read(authServiceProvider).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ==============================
            // 3. AREA ADMIN (Tersembunyi/Kecil)
            // ==============================
            const Divider(),
            TextButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mengupload data...")),
                );
                await SeederService().uploadInitialData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload Selesai!")),
                  );
                }
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.grey),
              label: const Text("Admin: Upload Ulang Data", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Item Statistik
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // Widget Helper: Menu List Tile
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}