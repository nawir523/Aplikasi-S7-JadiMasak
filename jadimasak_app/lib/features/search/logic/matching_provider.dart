import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../recipes/data/recipe_model.dart';
import '../../recipes/logic/recipe_provider.dart';
import '../../pantry/logic/pantry_controller.dart';

class RecipeMatch {
  final RecipeModel recipe;
  final List<String> missingIngredients;
  final int matchCount;

  RecipeMatch({
    required this.recipe,
    required this.missingIngredients,
    required this.matchCount,
  });
}

final matchingRecipesProvider = Provider<List<RecipeMatch>>((ref) {
  final recipesValue = ref.watch(recipeStreamProvider);
  final pantryValue = ref.watch(pantryItemsProvider);

  // 1. Cek apakah data sudah siap
  if (!recipesValue.hasValue || !pantryValue.hasValue) {
    return [];
  }

  // SAFEGUARD: Pastikan nilainya tidak null sebelum diakses
  final allRecipes = recipesValue.value ?? [];
  final pantryDocs = pantryValue.value?.docs ?? [];

  // 2. Ambil bahan kulkas dengan aman
  final myIngredients = pantryDocs.map((doc) {
    final data = doc.data() as Map<String, dynamic>?; // Bisa null
    
    // SAFEGUARD: Jika data null atau key tidak ada, pakai string kosong
    String rawName = data?['name']?.toString() ?? ''; 
    return rawName.toLowerCase().trim();
  }).where((name) => name.isNotEmpty).toList(); // Hapus yang kosong

  List<RecipeMatch> results = [];

  for (var recipe in allRecipes) {
    List<String> missing = [];
    int found = 0;

    // SAFEGUARD: Cek jika ingredients null/kosong
    if (recipe.ingredients.isEmpty) continue;

    for (var ingredient in recipe.ingredients) {
      // SAFEGUARD: Pastikan ingredient adalah Map dan punya 'name'
      if (ingredient is! Map) continue;
      
      String ingName = (ingredient['name']?.toString() ?? '').toLowerCase();
      if (ingName.isEmpty) continue;
      
      // Cek kecocokan
      bool isAvailable = myIngredients.any((myIng) => 
          ingName.contains(myIng) || myIng.contains(ingName));

      if (isAvailable) {
        found++;
      } else {
        missing.add(ingredient['name'].toString());
      }
    }

    // Tampilkan jika setidaknya ada 1 bahan yang cocok
    if (found > 0) { 
      results.add(RecipeMatch(
        recipe: recipe,
        missingIngredients: missing,
        matchCount: found,
      ));
    }
  }

  // Urutkan hasil
  results.sort((a, b) => a.missingIngredients.length.compareTo(b.missingIngredients.length));

  return results;
});