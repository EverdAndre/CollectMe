import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CollectionImagePickerBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imagePath;
  final VoidCallback onTap;
  final double width;
  final double height;

  const CollectionImagePickerBox({
    super.key,
    required this.imageBytes,
    required this.imagePath,
    required this.onTap,
    this.width = 120,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath == null && imageBytes == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined),
                  SizedBox(height: 4),
                  Text('IMG'),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  _previewImage(),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.edit_outlined, size: 18),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _previewImage() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
      );
    }

    if (_isBase64Image(imagePath!)) {
      return Image.memory(
        _base64ImageBytes(imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
      );
    }

    if (kIsWeb) {
      return const Icon(Icons.broken_image_outlined);
    }

    return Image.file(
      File(imagePath!),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
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
}
