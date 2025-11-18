import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String time;
  final String imageUrl;
  final int missingIngredients;

  const RecipeCard({
    super.key,
    required this.title,
    required this.time,
    required this.imageUrl,
    this.missingIngredients = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Gunakan withOpacity (abaikan warning deprecated dulu biar aman)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect agar gambar tidak keluar dari sudut melengkung
      child: ClipRRect( 
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Penting: Agar kartu menyesuaikan isi, bukan melar
          children: [
            // --- PERBAIKAN DI SINI: Jangan pakai Expanded ---
            // Kita pakai Container dengan tinggi tetap atau AspectRatio
            Container(
              height: 140, // Tinggi gambar dipatok 140px
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // -----------------------------------------------
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}