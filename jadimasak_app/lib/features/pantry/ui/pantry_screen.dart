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

  // Daftar Bahan Populer untuk "Quick Add"
  final List<String> _popularIngredients = [
    "Telur", "Nasi", "Ayam", "Tempe", "Tahu", 
    "Cabai", "Bawang", "Kecap", "Mie", "Sosis"
  ];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient(String name) {
    if (name.isEmpty) return;

    ref.read(pantryControllerProvider).addIngredient(
      name,
      onError: (msg) {
        if (mounted) {
          // Tampilkan pesan error simpel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.orange, duration: const Duration(seconds: 1)),
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
      backgroundColor: Colors.grey[50], // Background sedikit abu biar konten nonjol
      
      // Tombol Cari Resep (Dibuat Lebih Menonjol)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/search-result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            icon: const Icon(Icons.search, size: 24),
            label: const Text(
              "CARI RESEP DARI BAHAN INI", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          // 1. HEADER & INPUT
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Isi Kulkasku",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masukkan bahan yang kamu punya, kami carikan resepnya!",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  
                  // Input Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientController,
                          decoration: InputDecoration(
                            hintText: "Ketik bahan...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onSubmitted: (val) => _addIngredient(val.trim()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _addIngredient(_ingredientController.text.trim()),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  // --- FITUR BARU: PILIHAN CEPAT (QUICK ADD) ---
                  const Text(
                    "Tambahkan Cepat:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularIngredients.map((ing) {
                      return InkWell(
                        onTap: () => _addIngredient(ing),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "+ $ing", 
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 2. DAFTAR BAHAN YANG SUDAH MASUK
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Padding bawah besar utk tombol
            sliver: pantryAsync.when(
              data: (snapshot) {
                final docs = snapshot.docs;

                if (docs.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Kulkas masih kosong", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Ada ${docs.length} Bahan di Kulkas:", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        );
                      }
                      
                      // Data items mulai dari index 0, tapi karena ada header teks di index 0 list,
                      // kita geser index data dengan (index - 1)
                      final doc = docs[index - 1];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  data['name'] ?? '?',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                ref.read(pantryControllerProvider).deleteIngredient(doc.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: docs.length + 1, // +1 untuk Header Teks
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}