import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/recipe_model.dart';

// Stream Data Asli
final recipeStreamProvider = StreamProvider<List<RecipeModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('recipes')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return RecipeModel.fromMap(doc.id, doc.data());
        }).toList();
      });
});

// State Pencarian Teks
final searchQueryProvider = StateProvider<String>((ref) => '');

// State Kategori Terpilih (Default: 'Semua')
final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

// LOGIC UTAMA: Filter Gabungan
final filteredRecipesProvider = Provider<List<RecipeModel>>((ref) {
  final recipesAsync = ref.watch(recipeStreamProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return recipesAsync.when(
    data: (recipes) {
      return recipes.where((recipe) {
        // 1. Cek Pencarian Teks
        final matchesQuery = recipe.title.toLowerCase().contains(query);
        
        // 2. Cek Kategori
        // Jika 'Semua', lolos. Jika tidak, cek apakah kategori resep mengandung kata kunci.
        // Contoh: Pilih "Ayam", maka "Menu Utama / Ayam" akan lolos.
        bool matchesCategory = true;
        if (category != 'Semua') {
          matchesCategory = recipe.category.toLowerCase().contains(category.toLowerCase()) || 
                            recipe.title.toLowerCase().contains(category.toLowerCase());
        }

        return matchesQuery && matchesCategory;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});