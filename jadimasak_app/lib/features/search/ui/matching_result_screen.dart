import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../recipes/ui/widgets/recipe_card.dart';
import '../logic/matching_provider.dart';

class MatchingResultScreen extends ConsumerWidget {
  const MatchingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchingRecipesProvider);

    // Pisahkan hasil: Yang lengkap vs Yang kurang sedikit
    final perfectMatches = matches.where((m) => m.missingIngredients.isEmpty).toList();
    final incompleteMatches = matches.where((m) => m.missingIngredients.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saran Masak 🍳"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: matches.isEmpty
          ? const Center(
              child: Text("Belum ada resep yang cocok dengan bahanmu.\nCoba tambah bahan lain ke Kulkas!", textAlign: TextAlign.center),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // BAGIAN 1: COCOK SEMPURNA
                if (perfectMatches.isNotEmpty) ...[
                  const Text(
                    "🤩 Bisa dimasak sekarang! (Lengkap)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  ...perfectMatches.map((match) => _buildMatchCard(context, match)),
                  const SizedBox(height: 30),
                ],

                // BAGIAN 2: KURANG SEDIKIT
                if (incompleteMatches.isNotEmpty) ...[
                  const Text(
                    "🛒 Belanja sedikit lagi...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...incompleteMatches.map((match) => _buildMatchCard(context, match)),
                ],
              ],
            ),
    );
  }

  Widget _buildMatchCard(BuildContext context, RecipeMatch match) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          context.push('/recipe-detail', extra: match.recipe);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU RESEP (Tumpuk dengan Badge)
            Stack(
              children: [
                RecipeCard(
                  title: match.recipe.title,
                  time: match.recipe.time,
                  imageUrl: match.recipe.imageUrl,
                ),
                // Badge Merah (Jika ada yang kurang)
                if (match.missingIngredients.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: Text(
                        "Kurang ${match.missingIngredients.length}",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // 2. LIST BAHAN YANG KURANG (Teks di bawah kartu)
            if (match.missingIngredients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_basket_outlined, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Harus beli: ${match.missingIngredients.join(', ')}",
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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