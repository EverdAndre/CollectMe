import 'package:collection_app/widgets/collection_image_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TradeItemRow extends StatelessWidget {
  final TextEditingController observationsController;
  final String? imagePath;
  final Uint8List? imageBytes;
  final VoidCallback onImageTap;

  const TradeItemRow({
    super.key,
    required this.observationsController,
    required this.imagePath,
    required this.imageBytes,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CollectionImagePickerBox(
          width: 90,
          height: 70,
          imageBytes: imageBytes,
          imagePath: imagePath,
          onTap: onImageTap,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: observationsController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observacoes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }
}
