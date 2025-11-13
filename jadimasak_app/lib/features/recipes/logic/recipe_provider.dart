import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/recipe_model.dart';

// 1. Provider untuk mengambil stream data resep
final recipeStreamProvider = StreamProvider<List<RecipeModel>>((ref) {
  // Akses koleksi 'recipes' di Firestore
  return FirebaseFirestore.instance
      .collection('recipes')
      .snapshots() // Ambil snapshot (data real-time)
      .map((snapshot) {
        // Ubah setiap dokumen menjadi RecipeModel
        return snapshot.docs.map((doc) {
          return RecipeModel.fromMap(doc.id, doc.data());
        }).toList();
      });
});