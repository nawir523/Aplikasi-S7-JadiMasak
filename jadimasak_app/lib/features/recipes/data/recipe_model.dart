class RecipeModel {
  final String id;
  final String title;
  final String category; // <-- Baru
  final String time;
  final String servings; // <-- Baru
  final String imageUrl;
  final String instructions;
  final List<dynamic> ingredients;

  RecipeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.servings,
    required this.imageUrl,
    required this.instructions,
    required this.ingredients,
  });

  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? 'Tanpa Judul',
      // Beri nilai default agar aplikasi tidak error jika data lama belum punya kategori
      category: map['category'] ?? 'Umum', 
      time: map['time'] ?? '?? Menit',
      servings: map['servings'] ?? '1 Porsi',
      imageUrl: map['image_url'] ?? 'https://via.placeholder.com/150',
      instructions: map['instructions'] ?? 'Belum ada instruksi.',
      ingredients: map['ingredients_list'] ?? [],
    );
  }
}