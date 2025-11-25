import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../logic/bookmark_controller.dart';

class RecipeCard extends ConsumerWidget {
  final String id;
  final String title;
  final String category;
  final String time;
  final String servings;
  final String imageUrl;

  const RecipeCard({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.servings,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarkedIdsProvider).value ?? [];
    final isBookmarked = bookmarkedIds.contains(id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GAMBAR & TOMBOL (Stack)
          Stack(
            children: [
              // Gambar Resep
              AspectRatio(
                aspectRatio: 1.25, // Sedikit lebih pendek agar teks punya ruang
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),

              // Tombol Bookmark
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    ref.read(bookmarkControllerProvider).toggleBookmark(id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? AppColors.primary : Colors.grey,
                      size: 18, // Ukuran ikon sedikit dikecilkan
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. INFO TEXT
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10), // Padding disesuaikan
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Penting agar tidak memaksa ambil ruang sisa
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Font 13 biar aman
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8), // Ganti Spacer dengan jarak fix
                Row(
                  children: [
                    // Waktu
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    
                    const SizedBox(width: 8),
                    
                    // Porsi
                    const Icon(Icons.people_outline, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        servings, 
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}