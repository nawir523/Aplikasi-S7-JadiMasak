import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/recipe_model.dart';

// 1. Provider untuk mengambil stream data resep ASLI dari Firebase
final recipeStreamProvider = StreamProvider<List<RecipeModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('recipes')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return RecipeModel.fromMap(doc.id, doc.data());
        }).toList();
      });
});

// 2. Provider untuk menyimpan KATA KUNCI pencarian (State)
final searchQueryProvider = StateProvider<String>((ref) => '');

// 3. Provider PINTAR yang menggabungkan Resep + Kata Kunci
final filteredRecipesProvider = Provider<List<RecipeModel>>((ref) {
  // Ambil data resep (AsyncValue)
  final recipesAsync = ref.watch(recipeStreamProvider);
  // Ambil kata kunci
  final query = ref.watch(searchQueryProvider).toLowerCase();

  // Jika data resep masih loading/error, kembalikan list kosong
  return recipesAsync.when(
    data: (recipes) {
      if (query.isEmpty) {
        return recipes; // Jika tidak cari apa-apa, tampilkan semua
      }
      // Lakukan penyaringan (Filter)
      return recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});