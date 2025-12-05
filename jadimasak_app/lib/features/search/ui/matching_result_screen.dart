import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../recipes/ui/widgets/recipe_card.dart';
import '../logic/matching_provider.dart';
import '../../pantry/logic/shopping_controller.dart'; // Import controller belanja

class MatchingResultScreen extends ConsumerWidget {
  const MatchingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchingRecipesProvider);

    final perfectMatches = matches.where((m) => m.missingIngredients.isEmpty).toList();
    final incompleteMatches = matches.where((m) => m.missingIngredients.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saran Masak"),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Tombol Pintas ke Daftar Belanja
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.background),
            onPressed: () => context.push('/shopping-list'),
            tooltip: "Daftar Belanja",
          ),
        ],
      ),
      body: matches.isEmpty
          ? const Center(
              child: Text("Belum ada resep yang cocok.\nCoba tambah bahan lain!", textAlign: TextAlign.center),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (perfectMatches.isNotEmpty) ...[
                  const Text("Bisa dimasak sekarang!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 10),
                  ...perfectMatches.map((match) => _buildMatchCard(context, match, ref)), // Pass ref
                  const SizedBox(height: 30),
                ],

                if (incompleteMatches.isNotEmpty) ...[
                  const Text("Belanja sedikit lagi...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...incompleteMatches.map((match) => _buildMatchCard(context, match, ref)), // Pass ref
                ],
              ],
            ),
    );
  }

  // Tambahkan parameter WidgetRef ref
  Widget _buildMatchCard(BuildContext context, RecipeMatch match, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          context.push('/recipe-detail', extra: match.recipe);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                RecipeCard(
                  id: match.recipe.id,
                  title: match.recipe.title,
                  category: match.recipe.category,
                  time: match.recipe.time,
                  servings: match.recipe.servings,
                  imageUrl: match.recipe.imageUrl,
                ),
                
                if (match.missingIngredients.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        "Kurang ${match.missingIngredients.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Area Info Kurang & Tombol Belanja
            if (match.missingIngredients.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Kurang: ${match.missingIngredients.join(', ')}",
                        style: TextStyle(color: Colors.red[900], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // TOMBOL (+) KE KERANJANG
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Aksi: Masukkan ke Shopping List
                          ref.read(shoppingControllerProvider).addMultipleItems(
                            match.missingIngredients,
                            match.recipe.title,
                            );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bahan dimasukkan ke Daftar Belanja!"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text("Beli", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}