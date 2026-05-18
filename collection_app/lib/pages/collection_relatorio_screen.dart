import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/datasources/collection_datasource.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:collection_app/data/repositories/collection_repository.dart';
import 'package:collection_app/services/collection_relatorio_service.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

typedef _ReportItemToggle =
    void Function(CollectionModel collection, int index, bool selected);

class CollectionRelatorioScreen extends StatefulWidget {
  const CollectionRelatorioScreen({super.key});

  @override
  State<CollectionRelatorioScreen> createState() =>
      _CollectionRelatorioScreenState();
}

class _CollectionRelatorioScreenState extends State<CollectionRelatorioScreen> {
  final _repository = CollectionRepository(CollectionDataSource());
  final _relatorioService = CollectionRelatorioService();
  final Set<int> _selectedItemKeys = {};

  late Future<List<CollectionModel>> _collectionsFuture;
  _ReportType _selectedReportType = _ReportType.geral;
  bool _selectionInitialized = false;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _repository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatorio')),
      body: FutureBuilder<List<CollectionModel>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Nao foi possivel carregar o relatorio.'),
            );
          }

          final activeCollections = (snapshot.data ?? [])
              .where((item) => item.isActive)
              .toList();
          final filteredCollections = _selectedReportType.filter(
            activeCollections,
          );
          _initializeSelection(filteredCollections);

          final selectedCollections = _selectedCollections(filteredCollections);
          final reportData = _relatorioService.buildData(selectedCollections);
          final reportTitle = _selectedReportType.title;

          if (activeCollections.isEmpty) {
            return const Center(child: Text('Nenhum item ativo encontrado.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 920;
              final selector = _ReportSelector(
                collections: filteredCollections,
                selectedItemKeys: _selectedItemKeys,
                reportData: reportData,
                selectedReportType: _selectedReportType,
                reportTitle: reportTitle,
                itemKeyFor: _itemKeyFor,
                onReportTypeChanged: _changeReportType,
                onToggleItem: _toggleItem,
                onSelectAll: () => _selectAll(filteredCollections),
                onClearSelection: _clearSelection,
              );
              final preview = PdfPreview(
                build: (_) => _relatorioService.buildPdf(
                  selectedCollections,
                  title: reportTitle,
                ),
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                pdfFileName: 'relatorio_itens.pdf',
              );

              if (!isWide) {
                return Column(
                  children: [
                    SizedBox(height: 360, child: selector),
                    const Divider(height: 1),
                    Expanded(child: preview),
                  ],
                );
              }

              return Row(
                children: [
                  SizedBox(width: 380, child: selector),
                  const VerticalDivider(width: 1),
                  Expanded(child: preview),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _initializeSelection(List<CollectionModel> collections) {
    if (_selectionInitialized) {
      return;
    }

    _selectedItemKeys.addAll(
      collections.asMap().entries.map(
        (entry) => _itemKeyFor(entry.value, entry.key),
      ),
    );
    _selectionInitialized = true;
  }

  List<CollectionModel> _selectedCollections(List<CollectionModel> collections) {
    return collections.asMap().entries.where((entry) {
      return _selectedItemKeys.contains(_itemKeyFor(entry.value, entry.key));
    }).map((entry) {
      return entry.value;
    }).toList();
  }

  int _itemKeyFor(CollectionModel collection, int index) {
    return collection.id ?? -index - 1;
  }

  void _toggleItem(CollectionModel collection, int index, bool selected) {
    final key = _itemKeyFor(collection, index);

    setState(() {
      if (selected) {
        _selectedItemKeys.add(key);
      } else {
        _selectedItemKeys.remove(key);
      }
    });
  }

  void _selectAll(List<CollectionModel> collections) {
    setState(() {
      _selectedItemKeys
        ..clear()
        ..addAll(
          collections.asMap().entries.map(
                (entry) => _itemKeyFor(entry.value, entry.key),
              ),
        );
    });
  }

  void _clearSelection() {
    setState(_selectedItemKeys.clear);
  }

  void _changeReportType(_ReportType? reportType) {
    if (reportType == null || reportType == _selectedReportType) {
      return;
    }

    setState(() {
      _selectedReportType = reportType;
      _selectedItemKeys.clear();
      _selectionInitialized = false;
    });
  }
}

class _ReportSelector extends StatelessWidget {
  final List<CollectionModel> collections;
  final Set<int> selectedItemKeys;
  final CollectionRelatorioData reportData;
  final _ReportType selectedReportType;
  final String reportTitle;
  final int Function(CollectionModel collection, int index) itemKeyFor;
  final ValueChanged<_ReportType?> onReportTypeChanged;
  final _ReportItemToggle onToggleItem;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;

  const _ReportSelector({
    required this.collections,
    required this.selectedItemKeys,
    required this.reportData,
    required this.selectedReportType,
    required this.reportTitle,
    required this.itemKeyFor,
    required this.onReportTypeChanged,
    required this.onToggleItem,
    required this.onSelectAll,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<_ReportType>(
            initialValue: selectedReportType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Tipo de relatorio',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _ReportType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.label));
            }).toList(),
            onChanged: onReportTypeChanged,
          ),
          const SizedBox(height: 12),
          _ReportSummary(title: reportTitle, data: reportData),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Itens do relatorio',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Selecionar todos',
                onPressed: onSelectAll,
                icon: const Icon(Icons.select_all),
              ),
              IconButton(
                tooltip: 'Limpar selecao',
                onPressed: onClearSelection,
                icon: const Icon(Icons.deselect),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: collections.isEmpty
                ? const Center(child: Text('Nenhum item neste relatorio.'))
                : ListView.separated(
                    itemCount: collections.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      final selected = selectedItemKeys.contains(
                        itemKeyFor(collection, index),
                      );

                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: selected,
                        title: Text(
                          collection.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${collection.localArmazenamento} - ${collection.status.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onChanged: (value) {
                          onToggleItem(collection, index, value ?? false);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  final String title;
  final CollectionRelatorioData data;

  const _ReportSummary({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryLine(label: 'Total de Itens:', value: '${data.totalItens}'),
          _SummaryLine(
            label: 'Valor Estimado da Colecao:',
            value: _formatMoney(data.valorEstimadoColecao),
          ),
          _SummaryLine(
            label: 'Valor Custo da Colecao:',
            value: _formatMoney(data.valorCustoColecao),
          ),
          _SummaryLine(
            label: 'Quantidade Itens no Acervo:',
            value: '${data.quantidadeAcervo}',
          ),
          _SummaryLine(
            label: 'Quantidade Itens Emprestados:',
            value: '${data.quantidadeEmprestados}',
          ),
          _SummaryLine(
            label: 'Quantidade Itens Troca:',
            value: '${data.quantidadeTroca}',
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}

enum _ReportType {
  geral,
  acervo,
  vendidos,
  comprar,
  emprestados;

  String get label {
    switch (this) {
      case _ReportType.geral:
        return 'Geral';
      case _ReportType.acervo:
        return 'Acervo';
      case _ReportType.vendidos:
        return 'Vendidos';
      case _ReportType.comprar:
        return 'Comprar';
      case _ReportType.emprestados:
        return 'Emprestados';
    }
  }

  String get title {
    switch (this) {
      case _ReportType.geral:
        return 'Relatorio Geral de Itens';
      case _ReportType.acervo:
        return 'Relatorio de Itens no Acervo';
      case _ReportType.vendidos:
        return 'Relatorio de Itens Vendidos';
      case _ReportType.comprar:
        return 'Relatorio de Itens para Comprar';
      case _ReportType.emprestados:
        return 'Relatorio de Itens Emprestados';
    }
  }

  List<CollectionModel> filter(List<CollectionModel> collections) {
    switch (this) {
      case _ReportType.geral:
        return collections;
      case _ReportType.acervo:
        return _filterByStatus(collections, CollectionStatus.acervo);
      case _ReportType.vendidos:
        return _filterByStatus(collections, CollectionStatus.vendido);
      case _ReportType.comprar:
        return _filterByStatus(collections, CollectionStatus.comprar);
      case _ReportType.emprestados:
        return _filterByStatus(collections, CollectionStatus.emprestado);
    }
  }

  List<CollectionModel> _filterByStatus(
    List<CollectionModel> collections,
    CollectionStatus status,
  ) {
    return collections.where((item) => item.status == status).toList();
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label $value'),
    );
  }
}
