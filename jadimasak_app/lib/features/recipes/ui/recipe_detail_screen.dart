import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../data/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar yang bisa melebar/mengecil (SliverAppBar)
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true, // Agar tombol back tetap terlihat saat di-scroll
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                recipe.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Konten Resep
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0), // Efek menumpuk gambar
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Waktu
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        recipe.time,
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Divider(height: 40),

                  // Daftar Bahan
                  const Text(
                    "Bahan-bahan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map((ing) {
                    // 'ing' adalah Map {name: '...', qty: '...'}
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 10),
                          Text("${ing['name']} (${ing['qty']})"),
                        ],
                      ),
                    );
                  }), // Hapus toList() jika muncul error, tapi spread operator (...) biasanya aman

                  const Divider(height: 40),

                  // Instruksi / Cara Masak
                  const Text(
                    "Cara Memasak",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.instructions,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textPrimary),
                  ),
                  
                  const SizedBox(height: 40), // Spasi bawah
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}