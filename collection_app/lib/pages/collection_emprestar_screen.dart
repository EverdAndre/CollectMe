import 'package:collection_app/controllers/collection_form_controller.dart';
import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:collection_app/data/repositories/collection_repository.dart';
import 'package:collection_app/services/collection_image_service.dart';
import 'package:collection_app/widgets/collection_item_troca.dart';
import 'package:flutter/material.dart';

class CollectionEmprestarScreen extends StatefulWidget {
  final CollectionRepository repository;
  final CollectionModel collection;

  const CollectionEmprestarScreen({
    super.key,
    required this.repository,
    required this.collection,
  });

  @override
  State<CollectionEmprestarScreen> createState() =>
      _CollectionEmprestarScreenState();
}

class _CollectionEmprestarScreenState extends State<CollectionEmprestarScreen> {
  final _formController = CollectionFormController();
  final _imageService = CollectionImageService();

  bool _isSaving = false;

  bool get _hasEmprestar => widget.collection.emprestar != null;

  @override
  void initState() {
    super.initState();

    final emprestar = widget.collection.emprestar;

    if (emprestar != null) {
      _formController.fillFrom(emprestar);
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      initialDate: now,
      locale: const Locale('pt', 'BR'),
    );

    if (selectedDate == null) {
      return;
    }

    controller.text =
        '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }
    // Salva os dados de emprestimo dentro do item e muda o status para emprestado.
  Future<void> _saveEmprestar() async {
    if (!_formController.formKey.currentState!.validate()) {
      return;
    }

    final itemId = widget.collection.id;

    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item sem ID para emprestar.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final imagePathEntrada = await _imagePathEntradaForSave(itemId);
      final imagePathSaida = await _imagePathSaidaForSave(itemId);

      await widget.repository.updatePartialById(
        itemId,
        status: CollectionStatus.emprestado,
        emprestar: _formController.toModel(
          savedImagePathEntrada: imagePathEntrada,
          savedImagePathSaida: imagePathSaida,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _hasEmprestar
                ? 'Dados do emprestimo atualizados'
                : 'Item marcado como emprestado',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel emprestar o item.')),
      );
    }
  }

  Future<String?> _imagePathEntradaForSave(int itemId) {
    if (!_formController.imageEntradaChanged) {
      return Future.value(widget.collection.emprestar?.imagePathEntrada);
    }

    return _imageService.saveImageToRepository(
      itemId: itemId,
      imagePath: _formController.imagePathEntrada,
      imageBytes: _formController.imageBytesEntrada,
      imageExtension: _formController.imageExtensionEntrada,
    );
  }

  Future<String?> _imagePathSaidaForSave(int itemId) {
    if (!_formController.imageSaidaChanged) {
      return Future.value(widget.collection.emprestar?.imagePathSaida);
    }

    return _imageService.saveImageToRepository(
      itemId: itemId,
      imagePath: _formController.imagePathSaida,
      imageBytes: _formController.imageBytesSaida,
      imageExtension: _formController.imageExtensionSaida,
    );
  }

  Future<void> _pickEntradaImage() async {
    final image = await _imageService.pickImage();

    if (image == null) {
      return;
    }

    setState(() => _formController.setPickedEntradaImage(image));
  }

  Future<void> _pickSaidaImage() async {
    final image = await _imageService.pickImage();

    if (image == null) {
      return;
    }

    setState(() => _formController.setPickedSaidaImage(image));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _hasEmprestar ? 'Visualizar Emprestimo' : 'Emprestimo / Troca',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Formulario Emprestimo / Troca',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text('ID: ${widget.collection.id ?? ''}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _formController.nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: _formController.requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _formController.enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereco',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: _formController.requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _formController.dataEmprestimoController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data Emprestimo/Troca',
                            border: OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          onTap: () => _selectDate(
                            _formController.dataEmprestimoController,
                          ),
                          validator: _formController.requiredValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _formController.dataDevolucaoController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data Devolucao',
                            border: OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          onTap: () => _selectDate(
                            _formController.dataDevolucaoController,
                          ),
                          validator: _formController.requiredValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Item Troca Entrada',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TradeItemRow(
                    observationsController:
                        _formController.observacoesEntradaController,
                    imageBytes: _formController.imageBytesEntrada,
                    imagePath: _formController.imagePathEntrada,
                    onImageTap: _pickEntradaImage,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Item Troca Saida',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TradeItemRow(
                    observationsController:
                        _formController.observacoesSaidaController,
                    imageBytes: _formController.imageBytesSaida,
                    imagePath: _formController.imagePathSaida,
                    onImageTap: _pickSaidaImage,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveEmprestar,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.handshake_outlined),
                      label: Text(_hasEmprestar ? 'Atualizar' : 'Emprestar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
