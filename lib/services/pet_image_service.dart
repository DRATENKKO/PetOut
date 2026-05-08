import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PetImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _copyToPersistentStorage(image);
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied') {
        throw const PetImageException('Permiso de galería denegado');
      }
      throw PetImageException('Error al seleccionar foto: ${e.message}');
    } catch (e) {
      throw PetImageException('Error al seleccionar foto');
    }
  }

  Future<String?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _copyToPersistentStorage(image);
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        throw const PetImageException('Permiso de cámara denegado');
      }
      throw PetImageException('Error al tomar foto: ${e.message}');
    } catch (e) {
      throw PetImageException('Error al tomar foto');
    }
  }

  Future<String?> retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;
      if (response.file != null) {
        return await _copyToPersistentStorage(response.file!);
      }
      if (response.exception != null) {
        throw PetImageException(
          'Error recuperando foto: ${response.exception!.message}',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> _copyToPersistentStorage(XFile file) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String petsDir = path.join(appDir.path, 'petout', 'pets');
    await Directory(petsDir).create(recursive: true);

    final String fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String destPath = path.join(petsDir, fileName);

    final File sourceFile = File(file.path);
    await sourceFile.copy(destPath);

    return destPath;
  }

  Future<void> deletePetImageIfNeeded(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently ignore deletion errors
    }
  }

  bool validateFileExists(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    return File(imagePath).existsSync();
  }
}

class PetImageException implements Exception {
  final String message;
  const PetImageException(this.message);

  @override
  String toString() => message;
}
