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
    final filteredRecipes = ref.watch(filteredRecipesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isLoading = ref.watch(recipeStreamProvider).isLoading;

    final categories = ["Semua", "Nasi", "Ayam", "Daging", "Ikan", "Sayuran", "Camilan", "Minuman"];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [

          Stack(
            clipBehavior: Clip.none, // Izinkan elemen keluar dari kotak
            children: [
              // A. Background Oranye
              Container(
                height: 110, // Tinggi header oranye
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                 
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LOGO ASSET & NAMA
                    Row(
                      children: [
                        // Ganti Icon dengan Image Asset
                        Container(
                          padding: const EdgeInsets.all(2),
                          child: Image.asset(
                            'assets/images/logo2.png',
                            width: 45,
                            height: 45,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.restaurant, color: Color.from(alpha: 1, red: 1, green: 0.549, blue: 0)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Jadi Masak",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    // Tombol Tersimpan
                    GestureDetector(
                      onTap: () {
                        context.push('/saved-recipes');
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                           Icon(Icons.bookmark, color: Colors.white),
                           Text("Tersimpan", style: TextStyle(color: Colors.white, fontSize: 10))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // B. Search Bar (Mengambang / Terpisah)
              Positioned(
                bottom: -35, // Turunkan keluar dari kotak oranye
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: "Cari resep....",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Spasi kosong untuk Search Bar yang menjorok ke bawah tadi
          const SizedBox(height: 30),

          // ==============================
          // 2. KATEGORI
          // ==============================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 10),
                  ...categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        labelStyle: TextStyle(
                           color: isSelected ? Colors.white : Colors.black,
                           fontSize: 12,
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                        ),
                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).state = cat;
                        },
                        showCheckmark: false,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ==============================
          // 3. GRID RESEP
          // ==============================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text("Resep tidak ditemukan", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          // PERBAIKAN UTAMA OVERFLOW:
                          // Ubah aspect ratio menjadi lebih kecil (kartu lebih tinggi)
                          childAspectRatio: 0.7, 
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
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
                      ),
          ),
        ],
      ),
    );
  }
}