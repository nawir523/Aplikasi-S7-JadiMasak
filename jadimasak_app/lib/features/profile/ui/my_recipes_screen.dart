import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../recipes/data/recipe_model.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  // Fungsi Hapus Resep
  void _deleteRecipe(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Resep?"),
        content: const Text("Resep ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await FirebaseFirestore.instance.collection('recipes').doc(docId).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Resep dihapus."), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Resep Saya")),
      body: StreamBuilder<QuerySnapshot>(
        // Query: Ambil resep dimana userId == uid saya
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('userId', isEqualTo: uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Kamu belum menulis resep.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final recipe = RecipeModel.fromMap(docs[index].id, data);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Column(
                  children: [
                    // Tampilan Kartu Resep (Kita pakai RecipeCard yg sudah ada)
                    // Tapi kita bungkus biar tidak ada tombol bookmark double (opsional)
                    // Atau kita buat custom row sederhana saja biar rapi untuk manajemen
                    ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          recipe.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${recipe.time} • ${recipe.servings}"),
                      onTap: () {
                         context.push('/recipe-detail', extra: recipe);
                      },
                    ),
                    
                    // Tombol Aksi (Edit & Hapus)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit"),
                            onPressed: () {
                              // Pindah ke AddRecipe tapi bawa data (Mode Edit)
                              context.push('/edit-recipe', extra: recipe);
                            },
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text("Hapus", style: TextStyle(color: Colors.red)),
                            onPressed: () => _deleteRecipe(context, recipe.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}