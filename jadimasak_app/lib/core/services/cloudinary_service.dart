import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // GANTI DENGAN DATA KAMU DARI DASHBOARD TADI
  static const String cloudName = 'dlhpttdsj';
  static const String uploadPreset = 'jadimasak_app'; // Yg mode Unsigned

  final CloudinaryPublic cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path, 
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_photos', // Folder di Cloudinary (Opsional)
        ),
      );
      
      // Kembalikan URL gambar yang aman (https)
      return response.secureUrl;
    } catch (e) {
      throw 'Gagal upload ke Cloudinary: $e';
    }
  }
}