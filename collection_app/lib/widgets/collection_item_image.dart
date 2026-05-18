import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CollectionItemImage extends StatelessWidget {
  final String? imagePath;
  final double size;

  const CollectionItemImage({
    super.key,
    required this.imagePath,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return const Icon(Icons.image_outlined);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: _imageForPath(imagePath!),
    );
  }

  Widget _imageForPath(String path) {
    if (_isBase64Image(path)) {
      return Image.memory(
        _base64ImageBytes(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
      );
    }

    if (_isNetworkImage(path)) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
      );
    }

    if (kIsWeb) {
      return const Icon(Icons.image_outlined);
    }

    return Image.file(
      File(path),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
    );
  }

  bool _isBase64Image(String path) {
    return path.startsWith('data:image/');
  }

  Uint8List _base64ImageBytes(String path) {
    final commaIndex = path.indexOf(',');

    if (commaIndex < 0) {
      return Uint8List(0);
    }

    return base64Decode(path.substring(commaIndex + 1));
  }

  bool _isNetworkImage(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
