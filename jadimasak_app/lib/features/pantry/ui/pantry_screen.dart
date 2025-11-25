import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/pantry_controller.dart';

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
    
    _ingredientController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final pantryAsync = ref.watch(pantryItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // Floating Action Button Besar untuk Mencari Resep
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
      body: Column(
        children: [
          // 1. HEADER (Input Area)
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Isi Kulkasku",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Masukkan bahan yang kamu punya di rumah.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        decoration: InputDecoration(
                          hintText: "Contoh: Telur, Tempe, Bayam...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 10),
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

          // 2. DAFTAR BAHAN / EMPTY STATE
          Expanded(
            child: pantryAsync.when(
              data: (snapshot) {
                // --- EMPTY STATE (PANDUAN) ---
                if (snapshot.docs.isEmpty) {
                  return Center(
                    child: SingleChildScrollView( // Agar aman di layar kecil
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ilustrasi (Icon Besar)
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.kitchen_rounded, 
                              size: 80, 
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Teks Panduan
                          const Text(
                            "Kulkasmu Masih Kosong!",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Yuk, catat bahan-bahan yang ada di rumahmu sekarang. Nanti aku bantu carikan resep yang cocok!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.5),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Contoh Cara Pakai
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Colors.orange),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Tips: Masukkan bahan satu per satu. Contoh: 'Telur', lalu tekan (+).",
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // --- TAMPILAN ADA ISI (CHIPS) ---
                final docs = snapshot.docs;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ada ${docs.length} Bahan Tersedia:",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Chip(
                            label: Text(
                              data['name'] ?? '?',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(8),
                            deleteIcon: const Icon(Icons.close, size: 18, color: Colors.red),
                            onDeleted: () {
                              ref.read(pantryControllerProvider).deleteIngredient(doc.id);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // Tambahan ruang di bawah agar tidak tertutup tombol FAB
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}