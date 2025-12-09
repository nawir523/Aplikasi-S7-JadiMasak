import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Pastikan import ini
import '../../../core/constants/app_colors.dart';
import '../data/recipe_model.dart';
import '../../pantry/logic/shopping_controller.dart'; 
import '../../../core/widgets/banner_ad_widget.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
            
            // Tombol Edit
            actions: [
              if (FirebaseAuth.instance.currentUser?.uid == recipe.userId)
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    tooltip: "Edit Resep",
                    onPressed: () {
                      context.push('/edit-recipe', extra: recipe);
                    },
                  ),
                ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage( // Gunakan CachedNetworkImage
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
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
                  // Garis Handle
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

                  // KATEGORI (Badge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
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

                  // WAKTU & PORSI
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        recipe.time,
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      
                      const SizedBox(width: 24),

                      const Icon(Icons.people_outline, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        recipe.servings,
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 40),

                  // HEADER BAHAN + TOMBOL BELANJA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bahan-bahan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final ingredientNames = recipe.ingredients.map((e) {
                            String name = e is Map ? e['name'] : e.toString();
                            String qty = e is Map ? (e['qty'] ?? '') : '';
                            return qty.isNotEmpty && qty != 'secukupnya' ? "$name ($qty)" : name;
                          }).toList();

                          ref.read(shoppingControllerProvider).addMultipleItems(
                            ingredientNames,
                            recipe.title
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Bahan masuk ke Daftar Belanja!"), backgroundColor: Colors.green),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text("Belanja"),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // LIST BAHAN
                  if (recipe.ingredients.isEmpty)
                    const Text("Data bahan belum tersedia.", style: TextStyle(color: Colors.grey))
                  else
                    ...recipe.ingredients.map((ing) {
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
                            const Icon(Icons.fiber_manual_record, color: AppColors.secondary, size: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
                                  children: [
                                    TextSpan(text: name),
                                    if (qty.isNotEmpty) ...[
                                      const TextSpan(text: "  "),
                                      TextSpan(
                                        text: qty,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                      ),
                                    ]
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

                  // --- IKLAN BANNER (Dalam Column yang sama) ---
                  const Divider(),
                  const Center(child: Text("Disponsori", style: TextStyle(fontSize: 10, color: Colors.grey))),
                  const SizedBox(height: 10),
                  const BannerAdWidget(),
                  // -------------------------------------------

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