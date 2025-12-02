import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/logic/auth_controller.dart';
import '../../../core/services/cloudinary_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Isi nama awal dengan nama user sekarang
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  // Fungsi Pilih Gambar dari Galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi Simpan (Upload + Update Auth)
  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? photoUrl;

      // 1. Jika ada gambar baru, Upload ke Cloudinary dulu
      if (_selectedImage != null) {
        photoUrl = await CloudinaryService().uploadImage(_selectedImage!);
      }

      // 2. Update Data di Firebase Auth
      await ref.read(authServiceProvider).updateProfile(
        name: _nameController.text.trim(),
        photoUrl: photoUrl, // Kalau null, foto lama tidak berubah
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        context.pop(); // Kembali ke Profil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Gunakan foto yang baru dipilih (lokal) atau foto lama (url)
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (user?.photoURL != null) {
      imageProvider = NetworkImage(user!.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // FOTO PROFIL
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: imageProvider != null 
                          ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                          : null,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: imageProvider == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  // Ikon Kamera Kecil
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Ketuk foto untuk mengganti"),
            
            const SizedBox(height: 32),

            // INPUT NAMA
            CustomTextField(
              label: "Nama Lengkap",
              hint: "Masukkan namamu",
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            PrimaryButton(
              text: "Simpan Perubahan",
              isLoading: _isUploading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}