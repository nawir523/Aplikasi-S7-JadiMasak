import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Mengambil User ID saat ini
  String get _uid => _auth.currentUser!.uid;

  // Helper: Mengambil referensi koleksi 'pantry_items' milik user
  CollectionReference get _pantryRef {
    return _firestore.collection('users').doc(_uid).collection('pantry_items');
  }

  // 1. Ambil data bahan secara real-time (Stream)
  Stream<QuerySnapshot> getPantryStream() {
    // Urutkan berdasarkan waktu ditambahkan
    return _pantryRef.orderBy('created_at', descending: true).snapshots();
  }

  // 2. Tambah Bahan Baru
  Future<void> addIngredient(String name) async {
    // Cek dulu apakah bahan sudah ada (biar tidak duplikat)
    // Kita normalisasi nama jadi huruf kecil semua biar "Telur" == "telur"
    final normalizedName = name.trim().toLowerCase();
    
    // Query sederhana cek duplikat
    final existing = await _pantryRef.where('name_lowercase', isEqualTo: normalizedName).get();

    if (existing.docs.isNotEmpty) {
      throw 'Bahan "$name" sudah ada di kulkasmu!';
    }

    await _pantryRef.add({
      'name': name.trim(), // Nama asli (Kapitalisasi user)
      'name_lowercase': normalizedName, // Untuk pencarian/cek duplikat
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. Hapus Bahan
  Future<void> removeIngredient(String docId) async {
    await _pantryRef.doc(docId).delete();
  }
}