import 'package:collection_app/controllers/collection_item_controller.dart';
import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:collection_app/data/repositories/collection_repository.dart';
import 'package:collection_app/pages/collection_emprestar_screen.dart';
import 'package:collection_app/services/collection_image_service.dart';
import 'package:collection_app/widgets/collection_image_box.dart';
import 'package:flutter/material.dart';

class CollectionCadastrarItemScreen extends StatefulWidget {
  final CollectionRepository repository;
  final CollectionModel? collection;

  const CollectionCadastrarItemScreen({
    super.key,
    required this.repository,
    this.collection,
  });

  @override
  State<CollectionCadastrarItemScreen> createState() =>
      _CollectionCadastrarItemScreenState();
}
  // Controller agrupa os campos do formulario e as regras de validação.
class _CollectionCadastrarItemScreenState
    extends State<CollectionCadastrarItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formController = CollectionItemFormController();
  final _imageService = CollectionImageService();
  late Future<int> _nextIdFuture;
  bool _isSaving = false;

  bool get _isEditing => widget.collection != null;
  bool get _hasEmprestar => widget.collection?.emprestar != null;

  @override
  void initState() {
    super.initState();
    _nextIdFuture = widget.repository.nextId;

    final collection = widget.collection;

    if (collection == null) {
      return;
    }

    _formController.fillFrom(collection);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }
// Fluxo unico de salvar: atualiza item existente ou cria um novo registro.
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final itemId = widget.collection!.id;

        if (itemId == null) {
          throw StateError('Item sem id.');
        }

        await widget.repository.updatePartialById(
          itemId,
          nome: _formController.nomeController.text.trim(),
          descricao: _formController.descricaoController.text.trim(),
          imagePath: await _imagePathForSave(itemId),
          localArmazenamento: _formController.localController.text.trim(),
          valorCompra: _formController.parseMoney(
            _formController.valorCompraController.text,
          ),
          valorVenda: _formController.parseMoney(
            _formController.valorVendaController.text,
          ),
          status: _formController.selectedStatus,
        );
      } else {
        final itemId = await widget.repository.nextId;
        final collection = CollectionModel(
          id: itemId,
          nome: _formController.nomeController.text.trim(),
          descricao: _formController.descricaoController.text.trim(),
          imagePath: await _imagePathForSave(itemId),
          localArmazenamento: _formController.localController.text.trim(),
          valorCompra: _formController.parseMoney(
            _formController.valorCompraController.text,
          ),
          valorVenda: _formController.parseMoney(
            _formController.valorVendaController.text,
          ),
          status: _formController.selectedStatus,
        );

        await widget.repository.add(collection);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Item atualizado' : 'Item salvo')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel salvar o item.')),
      );
    }
  }
// Abre a tela de emprestimo
  Future<void> _openEmprestarScreen() async {
    final collection = widget.collection;

    if (collection == null) {
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CollectionEmprestarScreen(
          repository: widget.repository,
          collection: collection,
        ),
      ),
    );

    if (saved != true || !mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }
// Exclusao logica: mantem o registro no banco e marca isActive como falso.
  Future<void> _deleteItem() async {
    final collection = widget.collection;
    final itemId = collection?.id;

    if (collection == null || itemId == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Deseja excluir "${collection.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.repository.deactivateById(itemId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item excluido')));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel excluir o item.')),
      );
    }
  }

  Future<String?> _imagePathForSave(int itemId) {
    if (!_formController.imageChanged) {
      return Future.value(widget.collection?.imagePath);
    }

    return _imageService.saveImageToRepository(
      itemId: itemId,
      imagePath: _formController.imagePath,
      imageBytes: _formController.imageBytes,
      imageExtension: _formController.imageExtension,
    );
  }

  Future<void> _pickImage() async {
    final image = await _imageService.pickImage();

    if (image == null) {
      return;
    }

    setState(() {
      _formController.setPickedImage(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Item' : 'Cadastrar Item'),
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Cadastrar Item',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _ItemIdLabel(
                        id: widget.collection?.id,
                        nextIdFuture: _nextIdFuture,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 620;

                      if (isSmall) {
                        return Column(
                          children: [
                            CollectionImagePickerBox(
                              imageBytes: _formController.imageBytes,
                              imagePath: _formController.imagePath,
                              onTap: _pickImage,
                            ),
                            const SizedBox(height: 12),
                            _FormFields(
                              nomeController: _formController.nomeController,
                              descricaoController:
                                  _formController.descricaoController,
                              localController: _formController.localController,
                              valorCompraController:
                                  _formController.valorCompraController,
                              valorVendaController:
                                  _formController.valorVendaController,
                              selectedStatus: _formController.selectedStatus,
                              onStatusChanged: (value) {
                                setState(
                                  () => _formController.selectedStatus = value,
                                );
                              },
                              requiredValidator:
                                  _formController.requiredValidator,
                              moneyValidator: _formController.moneyValidator,
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CollectionImagePickerBox(
                                imageBytes: _formController.imageBytes,
                                imagePath: _formController.imagePath,
                                onTap: _pickImage,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller:
                                      _formController.valorCompraController,
                                  decoration: const InputDecoration(
                                    labelText: 'R\$ Compra',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: _formController.moneyValidator,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _FormFields(
                              nomeController: _formController.nomeController,
                              descricaoController:
                                  _formController.descricaoController,
                              localController: _formController.localController,
                              valorCompraController:
                                  _formController.valorCompraController,
                              valorVendaController:
                                  _formController.valorVendaController,
                              selectedStatus: _formController.selectedStatus,
                              onStatusChanged: (value) {
                                setState(
                                  () => _formController.selectedStatus = value,
                                );
                              },
                              showCompraField: false,
                              requiredValidator:
                                  _formController.requiredValidator,
                              moneyValidator: _formController.moneyValidator,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_isEditing) ...[
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _deleteItem,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Excluir'),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _openEmprestarScreen,
                          icon: const Icon(Icons.handshake_outlined),
                          label: Text(
                            _hasEmprestar
                                ? 'Visualizar emprestimo'
                                : 'Emprestar',
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveItem,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Salvar'),
                      ),
                    ],
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

class _FormFields extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController descricaoController;
  final TextEditingController localController;
  final TextEditingController valorCompraController;
  final TextEditingController valorVendaController;
  final CollectionStatus selectedStatus;
  final ValueChanged<CollectionStatus> onStatusChanged;
  final bool showCompraField;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> moneyValidator;

  const _FormFields({
    required this.nomeController,
    required this.descricaoController,
    required this.localController,
    required this.valorCompraController,
    required this.valorVendaController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.requiredValidator,
    required this.moneyValidator,
    this.showCompraField = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: requiredValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: valorVendaController,
                decoration: const InputDecoration(
                  labelText: 'R\$ Venda',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                validator: moneyValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: localController,
                decoration: const InputDecoration(
                  labelText: 'Local',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: requiredValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCompraField) ...[
              SizedBox(
                width: 120,
                child: TextFormField(
                  controller: valorCompraController,
                  decoration: const InputDecoration(
                    labelText: 'R\$ Compra',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: moneyValidator,
                ),
              ),
              const SizedBox(width: 12),
            ],
            SizedBox(
              width: 140,
              child: RadioGroup<CollectionStatus>(
                groupValue: selectedStatus,
                onChanged: (value) {
                  if (value != null) {
                    onStatusChanged(value);
                  }
                },
                child: Column(
                  children: [
                    for (final status in CollectionStatus.values)
                      _StatusRadio(label: _statusLabel(status), value: status),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: descricaoController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descricao',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: requiredValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ItemIdLabel extends StatelessWidget {
  final int? id;
  final Future<int> nextIdFuture;

  const _ItemIdLabel({required this.id, required this.nextIdFuture});

  @override
  Widget build(BuildContext context) {
    if (id != null) {
      return Text('ID: $id');
    }

    return FutureBuilder<int>(
      future: nextIdFuture,
      builder: (context, snapshot) {
        return Text('ID: ${snapshot.data ?? ''}');
      },
    );
  }
}

class _StatusRadio extends StatelessWidget {
  final String label;
  final CollectionStatus value;

  const _StatusRadio({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<CollectionStatus>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
    );
  }
}

String _statusLabel(CollectionStatus status) {
  switch (status) {
    case CollectionStatus.vendido:
      return 'Vendido';
    case CollectionStatus.emprestado:
      return 'Emprestado';
    case CollectionStatus.comprar:
      return 'Comprar';
    case CollectionStatus.acervo:
      return 'Acervo';
  }
}
