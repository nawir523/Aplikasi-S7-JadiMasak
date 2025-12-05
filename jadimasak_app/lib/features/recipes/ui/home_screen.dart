import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/recipe_provider.dart';
import 'widgets/recipe_card.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = ref.watch(filteredRecipesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isLoading = ref.watch(recipeStreamProvider).isLoading;

    final categories = ["Semua", ...AppConstants.recipeCategories];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. HEADER + SEARCH BAR (Desain Khusus)
          const SliverToBoxAdapter(
            child: _HomeHeader(), // Dipisah ke widget bawah biar rapi
          ),

          // 2. TOMBOL "TULIS RESEP"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), // Sedikit jarak dari search bar
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/add-recipe'),
                  borderRadius: BorderRadius.circular(15),
                  splashColor: AppColors.primary.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.08), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Punya Ide Masakan Baru?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Bagikan resep andalanmu di sini!",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. KATEGORI (STICKY HEADER)
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryHeaderDelegate(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (newCat) {
                ref.read(selectedCategoryProvider.notifier).state = newCat;
              },
            ),
          ),

          // 4. GRID RESEP
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredRecipes.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Resep tidak ditemukan",
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
              sliver: SliverFadeTransition(
                opacity: _fadeAnimation,
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = filteredRecipes[index];
                      return GestureDetector(
                        onTap: () => context.push('/recipe-detail', extra: recipe),
                        child: Hero(
                          tag: 'recipe_${recipe.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: RecipeCard(
                              id: recipe.id,
                              title: recipe.title,
                              category: recipe.category,
                              time: recipe.time,
                              servings: recipe.servings,
                              imageUrl: recipe.imageUrl,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredRecipes.length,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// === WIDGET HEADER TERPISAH (Agar kode lebih bersih) ===
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 170, // Tinggi total area header + separuh search bar
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. Background Oranye
          Container(
            height: 120, // Tinggi bagian oranye saja
            padding: const EdgeInsets.only(top: 35, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LOGO & NAMA (Tanpa Kotak Putih)
                Row(
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/logo2.png',
                        width: 45, // Sedikit lebih besar
                        height: 45,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.restaurant, color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Jadi Masak",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800, // Lebih tebal
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                // Tombol Tersimpan
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/saved-recipes'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bookmark_rounded, color: Colors.white, size: 28),
                          Text(
                            "Tersimpan",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          // 2. Search Bar (Posisi Absolute: Setengah di atas, setengah di bawah)
          Positioned(
            bottom: 20, // Menempel di dasar Container utama (yang tingginya 190)
            left: 10,
            right: 10,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Shadow sedikit lebih tebal
                    blurRadius: 15,
                    offset: const Offset(0, 8), // Shadow turun ke bawah
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: "Mau masak apa hari ini?",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  CategoryHeaderDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.fromLTRB(0, 35, 0, 10), 
      
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Kategori",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16, 
                color: AppColors.textPrimary
              ),
            ),
            const SizedBox(width: 16),
            ...categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: isSelected ? 0 : 1,
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => onCategorySelected(cat),
                    elevation: isSelected ? 3 : 0,
                    pressElevation: 3,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  // PERBAIKAN DI SINI:
  // Naikkan tinggi dari 65.0 menjadi 75.0 agar muat dengan padding baru
  double get maxExtent => 75.0; 

  @override
  double get minExtent => 75.0;

  @override
  bool shouldRebuild(covariant CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}