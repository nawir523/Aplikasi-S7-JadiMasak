import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _shoppingRef {
    return _firestore.collection('users').doc(_uid).collection('shopping_list');
  }

  Stream<QuerySnapshot> getShoppingList() {
    return _shoppingRef.orderBy('created_at', descending: true).snapshots();
  }

  // UPDATE: Tambah Item Manual (Masuk kategori 'Tambahan')
  Future<void> addItem(String name) async {
    final existing = await _shoppingRef.where('name', isEqualTo: name).get();
    if (existing.docs.isNotEmpty) return;

    await _shoppingRef.add({
      'name': name,
      'recipeName': 'Tambahan', // <-- Field Baru
      'isBought': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: Tambah Dari Resep (Simpan Nama Resepnya)
  Future<void> addMultipleItems(List<String> names, String recipeName) async {
    final batch = _firestore.batch();
    for (var name in names) {
      var docRef = _shoppingRef.doc(); 
      batch.set(docRef, {
        'name': name,
        'recipeName': recipeName, // <-- Field Baru (Asal Resep)
        'isBought': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> toggleStatus(String docId, bool currentStatus) async {
    await _shoppingRef.doc(docId).update({'isBought': !currentStatus});
  }

  Future<void> deleteItem(String docId) async {
    await _shoppingRef.doc(docId).delete();
  }
  
  Future<void> clearBoughtItems() async {
    final snapshot = await _shoppingRef.where('isBought', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

final shoppingControllerProvider = Provider((ref) => ShoppingController());

final shoppingListProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(shoppingControllerProvider).getShoppingList();
});