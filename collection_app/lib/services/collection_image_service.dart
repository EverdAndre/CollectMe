import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class CollectionImage {
  final String? path;
  final Uint8List? bytes;
  final String? extension;

  const CollectionImage({
    required this.path,
    required this.bytes,
    required this.extension,
  });
}

class CollectionImageService {
  Future<CollectionImage?> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      allowMultiple: false,
      withData: kIsWeb,
    );

    final file = result?.files.single;

    if (file == null) {
      return null;
    }

    return CollectionImage(
      path: file.path,
      bytes: file.bytes,
      extension: file.extension,
    );
  }

  Future<String?> saveImageToRepository({
    required int itemId,
    required String? imagePath,
    required Uint8List? imageBytes,
    required String? imageExtension,
  }) async {
    if (kIsWeb) {
      if (imageBytes == null) {
        return null;
      }

      final mimeType = mimeTypeFromExtension(imageExtension ?? 'jpg');
      return 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    }

    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final sourceFile = File(imagePath);

    if (!sourceFile.existsSync()) {
      return null;
    }

    final imagesDirectory = Directory('images');

    if (!imagesDirectory.existsSync()) {
      imagesDirectory.createSync(recursive: true);
    }

    final extension = fileExtension(sourceFile.path);
    final fileName =
        'item_${itemId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destinationPath =
        '${imagesDirectory.path}${Platform.pathSeparator}$fileName';

    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  String fileExtension(String path) {
    final separatorIndex = path.lastIndexOf(Platform.pathSeparator);
    final fileName = separatorIndex >= 0
        ? path.substring(separatorIndex + 1)
        : path;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex < 0) {
      return '.jpg';
    }

    return fileName.substring(dotIndex);
  }

  String mimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
