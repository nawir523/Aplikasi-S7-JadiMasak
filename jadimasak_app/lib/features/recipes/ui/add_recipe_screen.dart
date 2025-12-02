import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/cloudinary_service.dart';
import '../data/recipe_model.dart';

// Helper Class
class IngredientInput {
  TextEditingController nameController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  String type = 'Secukupnya';

  IngredientInput({String name = '', String qty = '', String typeVal = 'Secukupnya'}) {
    nameController.text = name;
    qtyController.text = qty;
    type = typeVal;
  }
}

class AddRecipeScreen extends ConsumerStatefulWidget {
  final RecipeModel? recipeToEdit;
  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _servingsUnit = 'Orang';
  List<IngredientInput> _ingredientInputs = [];

  File? _selectedImage;
  String? _oldImageUrl;
  bool _isUploading = false;
  String _selectedCategory = 'Menu Utama';

  final List<String> _categories = [
    'Menu Utama', 'Sayuran', 'Lauk Pauk', 'Camilan', 'Minuman', 'Dessert'
  ];

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi awal
    if (widget.recipeToEdit == null) {
      _ingredientInputs.add(IngredientInput());
    } else {
      // MODE EDIT: Isi data lama
      final r = widget.recipeToEdit!;
      _titleController.text = r.title;
      _selectedCategory = _categories.contains(r.category) ? r.category : 'Menu Utama';
      _timeController.text = r.time.replaceAll(RegExp(r'[^0-9]'), '');
      
      final servingParts = r.servings.split(' ');
      _servingsController.text = servingParts[0]; 
      if (servingParts.length > 1) {
        String unit = servingParts.sublist(1).join(' ');
        if (['Orang', 'Buah', 'Porsi', 'Loyang'].contains(unit)) {
          _servingsUnit = unit;
        }
      }

      _instructionsController.text = r.instructions;
      _oldImageUrl = r.imageUrl;

      for (var ing in r.ingredients) {
        String name = ing['name'] ?? '';
        String qty = ing['qty'] ?? '';
        String type = 'Detail';
        if (qty.toLowerCase() == 'secukupnya') {
          type = 'Secukupnya';
          qty = '';
        }
        _ingredientInputs.add(IngredientInput(name: name, qty: qty, typeVal: type));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _servingsController.dispose();
    _instructionsController.dispose();
    // Jangan lupa dispose controller di dalam list
    for (var input in _ingredientInputs) {
      input.nameController.dispose();
      input.qtyController.dispose();
    }
    super.dispose();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // --- FUNGSI BARU: BERSIHKAN FORM ---
  void _clearForm() {
    _titleController.clear();
    _timeController.clear();
    _servingsController.clear();
    _instructionsController.clear();
    
    setState(() {
      _selectedImage = null;
      _oldImageUrl = null;
      _selectedCategory = 'Menu Utama';
      _servingsUnit = 'Orang';
      // Reset bahan jadi 1 baris kosong
      _ingredientInputs = [IngredientInput()];
    });
  }
  // ----------------------------------

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submitRecipe() async {
    if (_titleController.text.isEmpty || 
        _timeController.text.isEmpty || 
        _servingsController.text.isEmpty ||
        (_selectedImage == null && _oldImageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data utama (Foto, Judul, Waktu, Porsi) wajib diisi!")),
      );
      return;
    }

    bool hasIngredient = _ingredientInputs.any((i) => i.nameController.text.isNotEmpty);
    if (!hasIngredient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimal isi satu bahan masakan!")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String imageUrl;
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService().uploadImage(_selectedImage!);
      } else {
        imageUrl = _oldImageUrl!;
      }

      List<Map<String, String>> ingredientsList = [];
      List<String> keywords = [];

      for (var input in _ingredientInputs) {
        String name = input.nameController.text.trim();
        if (name.isEmpty) continue;

        String finalQty;
        if (input.type == 'Secukupnya') {
          finalQty = 'secukupnya';
        } else {
          finalQty = input.qtyController.text.isEmpty ? '1 pcs' : input.qtyController.text.trim();
        }

        ingredientsList.add({
          'name': _toTitleCase(name),
          'qty': finalQty,
        });
        keywords.add(name.toLowerCase());
      }

      String formattedTime = "${_timeController.text.trim()} Menit";
      String formattedServings = "${_servingsController.text.trim()} $_servingsUnit";
      String titleCaseTitle = _toTitleCase(_titleController.text.trim());
      String currentUid = FirebaseAuth.instance.currentUser!.uid;

      final recipeData = {
        'userId': currentUid,
        'title': titleCaseTitle,
        'category': _selectedCategory,
        'time': formattedTime,
        'servings': formattedServings,
        'image_url': imageUrl,
        'instructions': _instructionsController.text.trim(),
        'ingredients_list': ingredientsList,
        'ingredients_text': keywords.join(' '),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.recipeToEdit == null) {
        recipeData['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('recipes').add(recipeData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resep berhasil disimpan!"), backgroundColor: Colors.green),
          );
          // BERSIHKAN FORM SETELAH SUKSES
          _clearForm();
          // Pindah ke Home
          context.go('/home');
        }
      } else {
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.recipeToEdit!.id)
            .update(recipeData);
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resep berhasil diupdate!"), backgroundColor: Colors.green),
          );
          context.pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipeToEdit != null ? "Edit Resep" : "Tulis Resep Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: (_selectedImage != null)
                      ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : (_oldImageUrl != null)
                          ? DecorationImage(image: NetworkImage(_oldImageUrl!), fit: BoxFit.cover)
                          : null,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: (_selectedImage == null && _oldImageUrl == null)
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          Text("Tambah Foto", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: "Judul Resep",
              hint: "Contoh: Sate Ayam Madura",
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            
            const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: "Waktu (Menit)",
                    hint: "30",
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: "Porsi",
                    hint: "2",
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _servingsUnit,
                    items: ['Orang', 'Buah', 'Porsi', 'Loyang'].map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (val) => setState(() => _servingsUnit = val!),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text("Bahan-bahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredientInputs.length,
              itemBuilder: (context, index) {
                final input = _ingredientInputs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: input.nameController,
                                decoration: const InputDecoration(
                                  hintText: "Nama Bahan (misal: Bawang)",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_ingredientInputs.length > 1)
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _ingredientInputs.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                        const Divider(height: 1),
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: input.type,
                              underline: const SizedBox(),
                              items: ['Secukupnya', 'Detail'].map((type) {
                                return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 12)));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  input.type = val!;
                                  if (val == 'Secukupnya') input.qtyController.clear();
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            if (input.type == 'Detail')
                              Expanded(
                                child: TextField(
                                  controller: input.qtyController,
                                  decoration: const InputDecoration(
                                    hintText: "Jml (misal: 1 buah)",
                                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  _ingredientInputs.add(IngredientInput());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah Baris Bahan"),
            ),

            const SizedBox(height: 24),
            
            const Text("Cara Memasak", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                controller: _instructionsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "1. Siapkan bahan...\n2. Tumis bawang...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            PrimaryButton(
              text: widget.recipeToEdit != null ? "Update Resep" : "Terbitkan Resep",
              isLoading: _isUploading,
              onPressed: _submitRecipe,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}