class RecipeModel {
  final String id;
  final String title;
  final String time;
  final String imageUrl;
  final String instructions; // Tambahan
  final List<dynamic> ingredients; // Tambahan (List bahan)

  RecipeModel({
    required this.id,
    required this.title,
    required this.time,
    required this.imageUrl,
    required this.instructions,
    required this.ingredients,
  });

  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? 'Tanpa Judul',
      time: map['time'] ?? '?? Menit',
      imageUrl: map['image_url'] ?? 'https://via.placeholder.com/150',
      // Ambil data tambahan, berikan default jika kosong
      instructions: map['instructions'] ?? 'Belum ada instruksi.',
      ingredients: map['ingredients_list'] ?? [],
    );
  }
}