import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Pastikan import model resep dan provider resep ini benar path-nya
import '../../recipes/data/recipe_model.dart';
import '../../recipes/logic/recipe_provider.dart';

// 1. MODEL UNTUK HASIL PENCARIAN
class RecipeMatch {
  final RecipeModel recipe;
  final List<String> matchingIngredients; // Bahan yang ada
  final List<String> missingIngredients;  // Bahan yang kurang

  RecipeMatch({
    required this.recipe,
    required this.matchingIngredients,
    required this.missingIngredients,
  });
}

// 2. CONTROLLER (LOGIC DATABASE)
class PantryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _pantryRef {
    return _firestore.collection('users').doc(_uid).collection('pantry');
  }

  // Stream: Ambil data real-time
  Stream<QuerySnapshot> getPantryStream() {
    return _pantryRef.orderBy('created_at', descending: true).snapshots();
  }

  // Fungsi: Tambah Bahan
  Future<void> addIngredient(String name, {Function(String)? onError}) async {
    try {
      final normalizeName = name.trim(); // Simpan nama asli (Case sensitive untuk display)
      final searchName = normalizeName.toLowerCase(); // Untuk pengecekan duplikat

      // Cek apakah bahan sudah ada?
      final existing = await _pantryRef.where('name_lower', isEqualTo: searchName).get();
      
      if (existing.docs.isNotEmpty) {
        if (onError != null) onError("Bahan '$name' sudah ada di kulkas!");
        return;
      }

      // Simpan ke Firestore
      await _pantryRef.add({
        'name': normalizeName,
        'name_lower': searchName,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (onError != null) onError("Gagal menambah: $e");
    }
  }

  // Fungsi: Hapus Bahan
  Future<void> deleteIngredient(String docId) async {
    await _pantryRef.doc(docId).delete();
  }
}

// 3. PROVIDER UTAMA
final pantryControllerProvider = Provider((ref) => PantryController());

// Provider Stream Data Kulkas
final pantryItemsProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(pantryControllerProvider).getPantryStream();
});

// 4. PROVIDER LOGIKA PENCOCOKAN (INI YANG HILANG SEBELUMNYA)
final matchingRecipesProvider = Provider<List<RecipeMatch>>((ref) {
  // A. Ambil semua resep (dari RecipeProvider)
  final allRecipesAsync = ref.watch(recipeStreamProvider);
  // B. Ambil bahan di kulkas (dari PantryProvider di atas)
  final pantryAsync = ref.watch(pantryItemsProvider);

  // C. Jika data belum siap, kembalikan list kosong
  if (!allRecipesAsync.hasValue || !pantryAsync.hasValue) {
    return [];
  }

  final allRecipes = allRecipesAsync.value!;
  final pantryDocs = pantryAsync.value!.docs;

  // D. Ubah data kulkas jadi List String lowercase biar gampang dicocokkan
  final pantryIngredients = pantryDocs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return (data['name'] ?? '').toString().toLowerCase();
  }).toList();

  List<RecipeMatch> matches = [];

  // E. Algoritma Pencocokan
  for (var recipe in allRecipes) {
    List<String> found = [];
    List<String> missing = [];

    for (var ingredient in recipe.ingredients) {
      String ingName = '';
      // Handle format bahan (bisa Map atau String)
      if (ingredient is Map) {
        ingName = (ingredient['name'] ?? '').toString().toLowerCase();
      } else {
        ingName = ingredient.toString().toLowerCase();
      }

      // Cek apakah nama bahan resep ada di dalam daftar kulkas
      // Contoh: Kulkas punya "Ayam", Resep minta "Daging Ayam" -> Cocok (Contains)
      bool isMatch = pantryIngredients.any((pantryItem) => 
          ingName.contains(pantryItem) || pantryItem.contains(ingName));

      if (isMatch) {
        found.add(ingName);
      } else {
        missing.add(ingName);
      }
    }

    // Syarat: Tampilkan resep jika setidaknya ada 1 bahan yang cocok
    if (found.isNotEmpty) {
      matches.add(RecipeMatch(
        recipe: recipe, 
        matchingIngredients: found, 
        missingIngredients: missing
      ));
    }
  }

  // F. Urutkan hasil: Yang paling sedikit kurang bahannya, taruh paling atas
  matches.sort((a, b) => a.missingIngredients.length.compareTo(b.missingIngredients.length));

  return matches;
});