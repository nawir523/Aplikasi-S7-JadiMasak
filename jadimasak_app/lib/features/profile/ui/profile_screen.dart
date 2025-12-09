import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambah Import Firestore
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../../recipes/logic/bookmark_controller.dart';
import '../../recipes/logic/recipe_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Fungsi Ganti Password
  void _changePassword(BuildContext context, String email) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Password"),
        content: Text("Kirim link reset password ke $email?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Link terkirim! Cek emailmu."), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI BARU: KIRIM SARAN ---
  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.feedback_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text("Beri Masukan", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Punya ide fitur baru atau menemukan bug? Ceritakan pada kami!",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4, // Kotak teks agak besar
              decoration: InputDecoration(
                hintText: "Tulis saranmu di sini...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final text = feedbackController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context); // Tutup dialog dulu
                
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  // Simpan ke Firestore
                  await FirebaseFirestore.instance.collection('user_feedback').add({
                    'userId': user?.uid,
                    'email': user?.email,
                    'message': text,
                    'created_at': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Terima kasih! Saranmu telah dikirim."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal mengirim saran."), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }
  // --------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    final savedRecipesAsync = ref.watch(bookmarkedIdsProvider);
    final myRecipesAsync = ref.watch(userRecipesCountProvider);
    final isProAsync = ref.watch(userSubscriptionProvider);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // HEADER PROFIL
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                    ),
                    child: ClipOval(
                      child: user.photoURL != null
                          ? CachedNetworkImage(
                              imageUrl: user.photoURL!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                              errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: Colors.grey),
                            )
                          : const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    user.displayName ?? "Koki Pemula",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? "",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        myRecipesAsync.when(
                          data: (count) => _buildStatItem("Resep Saya", count.toString()),
                          loading: () => _buildStatLoading("Resep Saya"),
                          error: (_, __) => _buildStatItem("Resep Saya", "-"),
                        ),
                        Container(height: 40, width: 1, color: Colors.grey[300]),
                        savedRecipesAsync.when(
                          data: (ids) => _buildStatItem("Tersimpan", ids.length.toString()),
                          loading: () => _buildStatLoading("Tersimpan"),
                          error: (_, __) => _buildStatItem("Tersimpan", "-"),
                        ),
                        Container(height: 40, width: 1, color: Colors.grey[300]),
                        isProAsync.when(
                          data: (isPro) => GestureDetector(
                            onTap: isPro ? null : () => context.push('/premium'),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isPro ? "PRO" : "Gratis",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 20, 
                                        color: isPro ? Colors.orange : AppColors.textPrimary
                                      ),
                                    ),
                                    if (!isPro) // Icon panah kecil kalau gratis
                                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary)
                                  ],
                                ),
                                const Text("Status", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          loading: () => _buildStatLoading("Status"),
                          error: (_,__) => _buildStatItem("Status", "-"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENU OPTIONS - GRUP 1
            _buildSectionHeader("Pengaturan Akun"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.edit_outlined,
                    color: Colors.blue,
                    title: "Edit Profil",
                    subtitle: "Ubah nama & foto",
                    onTap: () => context.push('/edit-profile'),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuTile(
                    icon: Icons.lock_outline,
                    color: Colors.orange,
                    title: "Ganti Password",
                    subtitle: "Kirim link reset ke email",
                    onTap: () => _changePassword(context, user.email!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENU OPTIONS - GRUP 2
            _buildSectionHeader("Aktivitas Saya"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                    title: "Resep Saya",
                    subtitle: "Kelola resep buatanmu",
                    onTap: () => context.push('/my-recipes'),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuTile(
                    icon: Icons.bookmark_outline,
                    color: Colors.pink,
                    title: "Koleksi Tersimpan",
                    subtitle: "Lihat resep favorit",
                    onTap: () => context.push('/saved-recipes'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENU OPTIONS - GRUP 3 (Update di sini)
            _buildSectionHeader("Lainnya"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.info_outline,
                    color: Colors.grey,
                    title: "Tentang Aplikasi",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Jadi Masak",
                        applicationVersion: "1.5.0",
                        applicationIcon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.restaurant_menu, color: Colors.white),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  
                  // --- TOMBOL SARAN BARU ---
                  _buildMenuTile(
                    icon: Icons.feedback_outlined,
                    color: Colors.purple,
                    title: "Beri Masukan / Saran",
                    subtitle: "Bantu kami jadi lebih baik",
                    onTap: () => _showFeedbackDialog(context),
                  ),
                  const Divider(height: 1, indent: 60),
                  // -------------------------

                  _buildMenuTile(
                    icon: Icons.logout,
                    color: Colors.red,
                    title: "Keluar",
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
            const Text("Versi 1.5.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatLoading(String label) {
    return Column(
      children: [
        const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}