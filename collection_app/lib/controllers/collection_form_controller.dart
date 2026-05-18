import 'package:collection_app/data/models/collection_model.dart';
import 'package:collection_app/services/collection_image_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CollectionFormController {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final dataEmprestimoController = TextEditingController();
  final dataDevolucaoController = TextEditingController();
  final observacoesEntradaController = TextEditingController();
  final observacoesSaidaController = TextEditingController();

  String? imagePathEntrada;
  Uint8List? imageBytesEntrada;
  String? imageExtensionEntrada;
  bool imageEntradaChanged = false;

  String? imagePathSaida;
  Uint8List? imageBytesSaida;
  String? imageExtensionSaida;
  bool imageSaidaChanged = false;

  void fillFrom(CollectionEmprestarModel emprestar) {
    nomeController.text = emprestar.nome;
    enderecoController.text = emprestar.endereco;
    dataEmprestimoController.text = emprestar.dataEmprestimo;
    dataDevolucaoController.text = emprestar.dataDevolucao;
    imagePathEntrada = emprestar.imagePathEntrada;
    imagePathSaida = emprestar.imagePathSaida;
    observacoesEntradaController.text = emprestar.observacoesEntrada;
    observacoesSaidaController.text = emprestar.observacoesSaida;
  }

  CollectionEmprestarModel toModel({
    required String? savedImagePathEntrada,
    required String? savedImagePathSaida,
  }) {
    return CollectionEmprestarModel(
      nome: nomeController.text.trim(),
      endereco: enderecoController.text.trim(),
      dataEmprestimo: dataEmprestimoController.text.trim(),
      dataDevolucao: dataDevolucaoController.text.trim(),
      imagePathEntrada: savedImagePathEntrada,
      imagePathSaida: savedImagePathSaida,
      observacoesEntrada: observacoesEntradaController.text.trim(),
      observacoesSaida: observacoesSaidaController.text.trim(),
    );
  }

  void setPickedEntradaImage(CollectionImage image) {
    imagePathEntrada = image.path;
    imageBytesEntrada = image.bytes;
    imageExtensionEntrada = image.extension;
    imageEntradaChanged = true;
  }

  void setPickedSaidaImage(CollectionImage image) {
    imagePathSaida = image.path;
    imageBytesSaida = image.bytes;
    imageExtensionSaida = image.extension;
    imageSaidaChanged = true;
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obrigatorio';
    }

    return null;
  }

  void dispose() {
    nomeController.dispose();
    enderecoController.dispose();
    dataEmprestimoController.dispose();
    dataDevolucaoController.dispose();
    observacoesEntradaController.dispose();
    observacoesSaidaController.dispose();
  }
}
