import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/dummy_recipes.dart'; // Import data yang baru kita buat

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadInitialData() async {
    final batch = _firestore.batch();
    
    print("Mulai upload ${dummyRecipes.length} resep...");

    for (var recipe in dummyRecipes) {
      var docRef = _firestore.collection('recipes').doc();
      
      // Kita siapkan data untuk Ingredients Text (pencarian)
      // Menggabungkan nama bahan menjadi satu string panjang
      List<dynamic> ingredients = recipe['ingredients_list'];
      String searchKeywords = ingredients.map((e) => e['name'].toString()).join(" ");

      batch.set(docRef, {
        "title": recipe['title'],
        "category": recipe['category'],
        "time": recipe['time'],
        "servings": recipe['servings'],
        "image_url": recipe['image_url'],
        "instructions": recipe['instructions'],
        "ingredients_list": ingredients,
        "ingredients_text": searchKeywords.toLowerCase(), // Untuk fitur pencarian bahan
        "created_at": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print("✅ Data resep BERHASIL di-upload ke Firestore!");
  }
}