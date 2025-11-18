import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/pantry_service.dart';

// Provider Service
final pantryServiceProvider = Provider((ref) => PantryService());

// Provider Stream (Untuk List Bahan di UI)
final pantryItemsProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.read(pantryServiceProvider).getPantryStream();
});

// Controller (Untuk aksi Tambah/Hapus)
class PantryController {
  final Ref ref;
  PantryController(this.ref);

  Future<void> addIngredient(String name, {Function(String)? onError}) async {
    try {
      await ref.read(pantryServiceProvider).addIngredient(name);
    } catch (e) {
      if (onError != null) onError(e.toString());
    }
  }

  Future<void> deleteIngredient(String docId) async {
    await ref.read(pantryServiceProvider).removeIngredient(docId);
  }
}

final pantryControllerProvider = Provider((ref) => PantryController(ref));