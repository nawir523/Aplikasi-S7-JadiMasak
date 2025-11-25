import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logic/recipe_provider.dart';
import '../logic/bookmark_controller.dart';
import 'widgets/recipe_card.dart';

class SavedRecipesScreen extends ConsumerWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil Data Semua Resep
    final allRecipesAsync = ref.watch(recipeStreamProvider);
    // 2. Ambil Daftar ID yang disimpan
    final bookmarkedIdsAsync = ref.watch(bookmarkedIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resep Tersimpan"), // Otomatis Oranye karena main.dart
      ),
      body: allRecipesAsync.when(
        data: (allRecipes) {
          return bookmarkedIdsAsync.when(
            data: (savedIds) {
              // 3. Lakukan Filter: Hanya resep yang ID-nya ada di savedIds
              final savedRecipes = allRecipes
                  .where((recipe) => savedIds.contains(recipe.id))
                  .toList();

              if (savedRecipes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Belum ada resep yang disimpan.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // 4. Tampilkan Grid (Sama seperti Home)
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: savedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = savedRecipes[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/recipe-detail', extra: recipe);
                    },
                    child: RecipeCard(
                      id: recipe.id,
                      title: recipe.title,
                      category: recipe.category,
                      time: recipe.time,
                      servings: recipe.servings,
                      imageUrl: recipe.imageUrl,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text("Gagal memuat bookmark")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Gagal memuat data")),
      ),
    );
  }
}