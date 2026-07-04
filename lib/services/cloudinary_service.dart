import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final cloudinary = CloudinaryPublic(
    'deir9cyru',
    'uzhai_uploads',
    cache: false,
  );

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
}