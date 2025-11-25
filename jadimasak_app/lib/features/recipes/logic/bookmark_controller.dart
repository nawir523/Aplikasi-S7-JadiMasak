import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // 1. Ambil daftar ID resep yang disimpan (Realtime)
  Stream<List<String>> getBookmarkedIds() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('saved_recipes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // 2. Toggle (Simpan/Hapus)
  Future<void> toggleBookmark(String recipeId) async {
    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('saved_recipes')
        .doc(recipeId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete(); // Hapus jika sudah ada
    } else {
      await docRef.set({'saved_at': FieldValue.serverTimestamp()}); // Simpan jika belum
    }
  }
}

// Provider
final bookmarkControllerProvider = Provider((ref) => BookmarkController());

// Provider Stream (List ID yang disimpan)
final bookmarkedIdsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(bookmarkControllerProvider).getBookmarkedIds();
});