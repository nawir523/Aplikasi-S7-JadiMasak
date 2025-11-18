import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/recipe_provider.dart';
import 'widgets/recipe_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(recipeStreamProvider);

    final filteredRecipes = ref.watch(filteredRecipesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // HEADER (Sapaan & Search)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Halo, Koki!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Mau masak apa hari ini?",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- SEARCH BAR ASLI (TextField) ---
                  TextField(
                    onChanged: (value) {
                      // Update kata kunci di Provider saat mengetik
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Cari 'Nasi Goreng'...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  // ------------------------------------
                  
                  const SizedBox(height: 24),
                  const Text(
                    "Resep Terbaru 🔥",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // GRID RESEP
          asyncData.when(
            data: (_) {
              // Jika hasil filter kosong
              if (filteredRecipes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Resep tidak ditemukan 😢"),
                    ),
                  ),
                );
              }

              // Tampilkan Grid dari filteredRecipes
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = filteredRecipes[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/recipe-detail', extra: recipe);
                        },
                        child: RecipeCard(
                          title: recipe.title,
                          time: recipe.time,
                          imageUrl: recipe.imageUrl,
                        ),
                      );
                    },
                    childCount: filteredRecipes.length,
                  ),
                ),
              );
            },
            // Loading State
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            // Error State
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text("Error: $err")),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}