import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/dummy_data.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadInitialData() async {
    final batch = _firestore.batch(); // Gunakan batch agar cepat (sekaligus)
    
    for (var recipe in initialRecipes) {
      // Buat dokumen baru di koleksi 'recipes' dengan ID acak
      var docRef = _firestore.collection('recipes').doc(); 
      batch.set(docRef, recipe);
    }

    await batch.commit();
    print("✅ Data resep berhasil di-upload!");
  }
}