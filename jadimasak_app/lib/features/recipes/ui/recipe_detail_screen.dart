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
          // 1. HEADER GAMBAR (Parallax)
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
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

          // 2. KONTEN RESEP
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Garis kecil di tengah atas
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], 
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // JUDUL
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // --- INFO BARU: KATEGORI (Badge) ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1), // Background oranye pudar
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- INFO BARU: WAKTU & PORSI (Row) ---
                  Row(
                    children: [
                      // Waktu
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        recipe.time,
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      
                      const SizedBox(width: 24), // Jarak pemisah

                      // Porsi
                      const Icon(Icons.people_outline, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        recipe.servings,
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 40),

                  // DAFTAR BAHAN
                  const Text(
                    "Bahan-bahan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Kita gunakan spread operator (...) untuk menampilkan list bahan
                  if (recipe.ingredients.isEmpty)
                    const Text("Data bahan belum tersedia.", style: TextStyle(color: Colors.grey))
                  else
                    ...recipe.ingredients.map((ing) {
                      // ing bisa berupa Map atau String (jaga-jaga)
                      String name = '';
                      String qty = '';
                      
                      if (ing is Map) {
                        name = ing['name'] ?? '';
                        qty = ing['qty'] ?? '';
                      } else {
                        name = ing.toString();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                  children: [
                                    TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    if (qty.isNotEmpty) 
                                      TextSpan(text: " ($qty)", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const Divider(height: 40),

                  // CARA MEMASAK
                  const Text(
                    "Cara Memasak",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.instructions,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textPrimary),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}