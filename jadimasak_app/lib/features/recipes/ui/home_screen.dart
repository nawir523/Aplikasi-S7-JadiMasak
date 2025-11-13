import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/recipe_provider.dart';
import 'widgets/recipe_card.dart';

// 3. Ubah jadi ConsumerWidget agar bisa mendengar Provider
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4. Pantau data dari StreamProvider
    final recipeAsyncValue = ref.watch(recipeStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // HEADER (Sapaan & Search) - Tetap sama
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
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text("Cari Resep...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Resep Terbaru 🔥",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 5. GRID RESEP (Dinamis dari Firebase)
          recipeAsyncValue.when(
            // A. Jika Data Tersedia
            data: (recipes) {
              if (recipes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("Belum ada resep.")),
                );
              }
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
                      final recipe = recipes[index];
                      
                      // Bungkus RecipeCard agar bisa diklik
                      return GestureDetector(
                        onTap: () {
                          // Pindah ke detail sambil bawa data 'recipe'
                          // Gunakan context.push agar bisa di-back
                          context.push('/recipe-detail', extra: recipe);
                        },
                        child: RecipeCard(
                          title: recipe.title,
                          time: recipe.time,
                          imageUrl: recipe.imageUrl,
                        ),
                      );
                    },
                    childCount: recipes.length,
                  ),
                ),
              );
            },
            
            // B. Jika Sedang Loading (Muncul muter-muter)
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            
            // C. Jika Error
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