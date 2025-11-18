import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/pantry_controller.dart';
import 'package:go_router/go_router.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _ingredientController = TextEditingController();

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  // Fungsi helper saat tombol ditekan
  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) return;

    ref.read(pantryControllerProvider).addIngredient(
      text,
      onError: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      },
    );
    
    _ingredientController.clear(); // Kosongkan input setelah tambah
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari stream
    final pantryAsync = ref.watch(pantryItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Kulkasku", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. INPUT AREA (Putih)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Apa yang kamu punya?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        decoration: InputDecoration(
                          hintText: "Contoh: Telur, Bayam, Tahu...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: (_) => _addIngredient(), // Bisa tekan Enter di keyboard
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol Tambah
                    ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. DAFTAR BAHAN (Chips)
          Expanded(
            child: pantryAsync.when(
              data: (snapshot) {
                if (snapshot.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "Kulkas masih kosong nih!",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.docs;

                // Tampilan Wrap (Chip berjejer)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 10, // Jarak horizontal
                    runSpacing: 10, // Jarak vertikal
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Chip(
                        label: Text(
                          data['name'] ?? '?',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 1,
                        shadowColor: Colors.grey.withValues(alpha: 0.2),
                        padding: const EdgeInsets.all(8),
                        deleteIcon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onDeleted: () {
                          // Logika Hapus
                          ref.read(pantryControllerProvider).deleteIngredient(doc.id);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/search-result');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.restaurant_menu, color: Colors.white),
        label: const Text(
          "Masak Apa Ya?", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}