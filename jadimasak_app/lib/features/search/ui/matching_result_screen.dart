import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Pastikan import ini
import '../../../core/constants/app_colors.dart';
import '../../pantry/logic/pantry_controller.dart';
import '../../pantry/logic/shopping_controller.dart'; // Import Shopping Controller

class MatchingResultScreen extends ConsumerWidget {
  const MatchingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchingRecipesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Hasil Pencarian", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: matches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Tidak ada resep yang cocok.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final recipe = match.recipe;
                final missingCount = match.missingIngredients.length;

                return GestureDetector(
                  onTap: () {
                    context.push('/recipe-detail', extra: recipe);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 1. GAMBAR & INFO UTAMA
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16), // Gambar kotak di kiri
                              ),
                              child: CachedNetworkImage(
                                imageUrl: recipe.imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                              ),
                            ),
                            
                            // Teks Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${match.matchingIngredients.length} bahan tersedia",
                                      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      missingCount == 0 
                                          ? "Siap masak!" 
                                          : "Kurang $missingCount bahan",
                                      style: TextStyle(
                                        color: missingCount == 0 ? AppColors.primary : Colors.red, 
                                        fontSize: 12
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 2. BAGIAN MISSING INGREDIENTS & TOMBOL BELI
                        if (missingCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Kurang: ${match.missingIngredients.join(', ')}",
                                    style: TextStyle(color: Colors.red[700], fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                
                                // --- PERBAIKAN TOMBOL BELANJA DI SINI ---
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // PANGGIL FUNGSI ADD DENGAN JUDUL RESEP
                                      ref.read(shoppingControllerProvider).addMultipleItems(
                                        match.missingIngredients, // List bahan
                                        recipe.title              // Judul Resep (Ini yang kemarin kurang)
                                      );

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Bahan kurang masuk ke Daftar Belanja!"),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_shopping_cart, size: 14),
                                    label: const Text("Beli", style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                  ),
                                ),
                                // ----------------------------------------
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}