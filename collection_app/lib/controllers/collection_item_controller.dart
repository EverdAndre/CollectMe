import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:collection_app/services/collection_image_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CollectionItemFormController {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final localController = TextEditingController();
  final valorCompraController = TextEditingController();
  final valorVendaController = TextEditingController();

  String? imagePath;
  Uint8List? imageBytes;
  String? imageExtension;
  CollectionStatus selectedStatus = CollectionStatus.acervo;
  bool imageChanged = false;

  void fillFrom(CollectionModel collection) {
    nomeController.text = collection.nome;
    descricaoController.text = collection.descricao;
    localController.text = collection.localArmazenamento;
    valorCompraController.text = collection.valorCompra.toStringAsFixed(2);
    valorVendaController.text = collection.valorVenda.toStringAsFixed(2);
    imagePath = collection.imagePath;
    selectedStatus = collection.status;
  }

  void setPickedImage(CollectionImage image) {
    imagePath = image.path;
    imageBytes = image.bytes;
    imageExtension = image.extension;
    imageChanged = true;
  }

  double parseMoney(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obrigatorio';
    }

    return null;
  }

  String? moneyValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    if (double.tryParse(text.replaceAll(',', '.')) == null) {
      return 'Valor invalido';
    }

    return null;
  }

  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    localController.dispose();
    valorCompraController.dispose();
    valorVendaController.dispose();
  }
}
