import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/shopping_controller.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background agak abu biar grup terlihat
      appBar: AppBar(
        title: const Text("Daftar Belanja"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Bersihkan yang sudah dibeli",
            onPressed: () {
              ref.read(shoppingControllerProvider).clearBoughtItems();
            },
          ),
        ],
      ),
      body: shoppingAsync.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Belanjaan kosong!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 1. LOGIKA GROUPING (Mengelompokkan berdasarkan recipeName)
          Map<String, List<DocumentSnapshot>> groupedItems = {};
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            // Ambil nama resep, jika null masuk ke 'Tambahan'
            String recipe = data['recipeName'] ?? 'Tambahan';
            
            if (groupedItems[recipe] == null) {
              groupedItems[recipe] = [];
            }
            groupedItems[recipe]!.add(doc);
          }

          // 2. TAMPILKAN LIST GROUP
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedItems.length,
            itemBuilder: (context, index) {
              String key = groupedItems.keys.elementAt(index); // Nama Resep
              List<DocumentSnapshot> items = groupedItems[key]!; // Daftar Bahan

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER GRUP (Nama Resep)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          key == 'Tambahan' ? Icons.edit_note : Icons.restaurant_menu, 
                          size: 18, 
                          color: AppColors.primary
                        ),
                        const SizedBox(width: 8),
                        Text(
                          key,
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.textPrimary
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ITEM BELANJA (Card Putih per Grup)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      children: items.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final isBought = data['isBought'] ?? false;
                        
                        return Column(
                          children: [
                            ListTile(
                              leading: Checkbox(
                                value: isBought,
                                activeColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  ref.read(shoppingControllerProvider).toggleStatus(doc.id, isBought);
                                },
                              ),
                              title: Text(
                                data['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: isBought ? TextDecoration.lineThrough : null,
                                  color: isBought ? Colors.grey : Colors.black87,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                onPressed: () {
                                  ref.read(shoppingControllerProvider).deleteItem(doc.id);
                                },
                              ),
                            ),
                            // Garis pemisah antar item (kecuali yang terakhir)
                            if (doc != items.last) 
                              const Divider(height: 1, indent: 16, endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16), // Jarak antar grup
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Error: $err")),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDialog(context, ref),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Belanjaan"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Misal: Sabun Cuci..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(shoppingControllerProvider).addItem(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }
}