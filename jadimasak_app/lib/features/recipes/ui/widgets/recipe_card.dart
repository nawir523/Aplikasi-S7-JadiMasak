import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import ini wajib!
import '../../../../core/constants/app_colors.dart';
import '../../logic/bookmark_controller.dart';

class RecipeCard extends ConsumerWidget {
  final String id;
  final String title;
  final String category;
  final String time;
  final String servings;
  final String imageUrl;

  // Gunakan const constructor agar widget tidak rebuilt jika parameter sama
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
    // Optimasi: Watch hanya nilai spesifik, bukan seluruh controller jika memungkinkan
    // Tapi karena kita watch Future/Stream, ini sudah standar.
    final bookmarkedIds = ref.watch(bookmarkedIdsProvider).value ?? [];
    final isBookmarked = bookmarkedIds.contains(id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Shadow lebih tipis biar ringan render-nya
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GAMBAR (Optimized)
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.25,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  // GANTI Image.network DENGAN CachedNetworkImage
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    // Placeholder saat loading (Ringan)
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.restaurant, color: Colors.grey, size: 20),
                      ),
                    ),
                    // Widget jika error / gagal load
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                    // Optimasi memori: Resize gambar agar tidak terlalu besar di memori
                    memCacheWidth: 400, // Cukup 400px lebarnya untuk thumbnail
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
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. INFO TEXT
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 8),
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