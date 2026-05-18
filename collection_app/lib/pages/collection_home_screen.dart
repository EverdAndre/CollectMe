import 'package:collection_app/core/enum/collection_filtro.dart';
import 'package:collection_app/data/datasources/collection_datasource.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:collection_app/data/repositories/collection_repository.dart';
import 'package:collection_app/pages/collection_cadastraritem_screen.dart';
import 'package:collection_app/routes/app_routes.dart';
import 'package:collection_app/services/app_exit_service.dart';
import 'package:collection_app/widgets/collection_item_image.dart';
import 'package:flutter/material.dart';

class CollectionHomeScreen extends StatefulWidget {
  const CollectionHomeScreen({super.key});

  @override
  State<CollectionHomeScreen> createState() => _CollectionHomeScreenState();
}
// A Home conversa com o repositorio ele acesso ao banco.

class _CollectionHomeScreenState extends State<CollectionHomeScreen> {

  final CollectionRepository _repository = CollectionRepository(
    CollectionDataSource(),
  );
  final TextEditingController _searchController = TextEditingController();

  late Future<List<CollectionModel>> _collectionsFuture;
  CollectionFiltro? _selectedFilter;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCollections() {

    _collectionsFuture = _repository.getAll();
  }
// Recarrega a lista depois de cadastrar, editar, excluir ou puxar para atualizar.
  Future<void> _refreshCollections() async {
    setState(_loadCollections);
    await _collectionsFuture;
  }
// Itens excluidos sao apenas desativados
  List<CollectionModel> _applyFilters(List<CollectionModel> collections) {
    var filteredCollections = collections
        .where((item) => item.isActive)
        .toList();

    if (_searchText.isNotEmpty) {
      final search = _searchText.toLowerCase();
      filteredCollections = filteredCollections.where((item) {
        return item.nome.toLowerCase().contains(search) ||
            item.descricao.toLowerCase().contains(search) ||
            item.localArmazenamento.toLowerCase().contains(search);
      }).toList();
    }

    switch (_selectedFilter) {
      case CollectionFiltro.nome:
      case CollectionFiltro.ordemAlfabetica:
        filteredCollections.sort((a, b) => a.nome.compareTo(b.nome));
      case CollectionFiltro.valorAsc:
        filteredCollections.sort(
          (a, b) => a.valorVenda.compareTo(b.valorVenda),
        );
      case CollectionFiltro.valorDesc:
        filteredCollections.sort(
          (a, b) => b.valorVenda.compareTo(a.valorVenda),
        );
      case CollectionFiltro.vendido:
      case CollectionFiltro.emprestado:
      case CollectionFiltro.comprar:
      case CollectionFiltro.acervo:
        filteredCollections = filteredCollections
            .where((item) => item.status.name == _selectedFilter!.name)
            .toList();
      case null:
        break;
    }

    return filteredCollections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _HomeHeader(
                selectedFilter: _selectedFilter,
                searchController: _searchController,
                onFilterChanged: (filter) {
                  setState(() => _selectedFilter = filter);
                },
                onSearchChanged: (value) {
                  setState(() => _searchText = value.trim());
                },
                onNewItem: _openNewItemScreen,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<CollectionModel>>(
                  future: _collectionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Não foi possível carregar a coleção.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final collections = _applyFilters(snapshot.data ?? []);

                    if (collections.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshCollections,
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.28,
                            ),
                            const Icon(Icons.inventory_2_outlined, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum item na coleção.',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshCollections,
                      child: _CollectionTable(
                        collections: collections,
                        onEdit: _openEditItemScreen,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNewItemScreen() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            CollectionCadastrarItemScreen(repository: _repository),
      ),
    );

    if (saved == true) {
      await _refreshCollections();
    }
  }

  Future<void> _openEditItemScreen(CollectionModel collection) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CollectionCadastrarItemScreen(
          repository: _repository,
          collection: collection,
        ),
      ),
    );

    if (saved == true) {
      await _refreshCollections();
    }
  }

}

class _HomeHeader extends StatelessWidget {
  final CollectionFiltro? selectedFilter;
  final TextEditingController searchController;
  final ValueChanged<CollectionFiltro?> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNewItem;

  const _HomeHeader({
    required this.selectedFilter,
    required this.searchController,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onNewItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              PopupMenuButton<_MainMenuAction>(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu),
                onSelected: (action) => _handleMainMenuAction(context, action),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _MainMenuAction.newItem,
                    child: Text('Novo Item'),
                  ),
                  PopupMenuItem(
                    value: _MainMenuAction.report,
                    child: Text('Relatorio'),
                  ),
                ],
              ),
              const Expanded(
                child: Text(
                  'Bem Vindo a Sua Coleção',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuButton<_HomeMenuAction>(
                tooltip: 'Opcoes',
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => _handleMenuAction(context, action),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _HomeMenuAction.about,
                    child: Text('Sobre'),
                  ),
                  PopupMenuItem(
                    value: _HomeMenuAction.exit,
                    child: Text('Sair'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<CollectionFiltro?>(
                  initialValue: selectedFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...CollectionFiltro.values.map(
                      (filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter.name),
                      ),
                    ),
                  ],
                  onChanged: onFilterChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Item',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Meus Itens',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
    // Menu de opcoes: navega para Sobre ou encerra o app pela camada de servico.
  void _handleMenuAction(BuildContext context, _HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.about:
        Navigator.of(context).pushNamed(AppRoutes.about);
      case _HomeMenuAction.exit:
        exitApp();
    }
  }
// Menu principal: abre cadastro ou relatorio.
  void _handleMainMenuAction(BuildContext context, _MainMenuAction action) {
    switch (action) {
      case _MainMenuAction.newItem:
        onNewItem();
      case _MainMenuAction.report:
        Navigator.of(context).pushNamed(AppRoutes.relatorio);
    }
  }
}

enum _MainMenuAction { newItem, report }

enum _HomeMenuAction { about, exit }

class _CollectionTable extends StatelessWidget {
  final List<CollectionModel> collections;
  final ValueChanged<CollectionModel> onEdit;

  const _CollectionTable({
    required this.collections,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 760,
        child: Scrollbar(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8),
            itemCount: collections.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _CollectionTableHeader();
              }

              final collection = collections[index - 1];
              return _CollectionTableRow(
                collection: collection,
                displayId: index,
                onEdit: onEdit,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CollectionTableHeader extends StatelessWidget {
  const _CollectionTableHeader();

  @override
  Widget build(BuildContext context) {
    return const _TableShell(
      child: Row(
        children: [
          _Cell(width: 42, child: Text('ID', textAlign: TextAlign.center)),
          _Cell(width: 46, child: Text('IMG', textAlign: TextAlign.center)),
          _Cell(
            flex: 2,
            child: Text('Nome do Item', textAlign: TextAlign.center),
          ),
          _Cell(width: 58, child: Text('Local', textAlign: TextAlign.center)),
          _Cell(
            width: 62,
            child: Text('R\$ Compra', textAlign: TextAlign.center),
          ),
          _Cell(
            width: 62,
            child: Text('R\$ Venda', textAlign: TextAlign.center),
          ),
          _Cell(width: 58, child: Text('Status', textAlign: TextAlign.center)),
          _Cell(width: 46, child: Text('Edit', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _CollectionTableRow extends StatelessWidget {
  final CollectionModel collection;
  final int displayId;
  final ValueChanged<CollectionModel> onEdit;

  const _CollectionTableRow({
    required this.collection,
    required this.displayId,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return _TableShell(
      child: Row(
        children: [
          _Cell(
            width: 42,
            child: Text('$displayId', textAlign: TextAlign.center),
          ),
          _Cell(
            width: 46,
            child: CollectionItemImage(imagePath: collection.imagePath),
          ),
          _Cell(
            flex: 2,
            child: Text(
              collection.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          _Cell(
            width: 58,
            child: Text(
              collection.localArmazenamento,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          _Cell(
            width: 62,
            child: Text(
              collection.valorCompra.toStringAsFixed(2),
              textAlign: TextAlign.center,
            ),
          ),
          _Cell(
            width: 62,
            child: Text(
              collection.valorVenda.toStringAsFixed(2),
              textAlign: TextAlign.center,
            ),
          ),
          _Cell(
            width: 58,
            child: Text(
              collection.status.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          _Cell(
            width: 46,
            child: IconButton(
              tooltip: 'Editar',
              onPressed: () => onEdit(collection),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableShell extends StatelessWidget {
  final Widget child;

  const _TableShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Cell extends StatelessWidget {
  final Widget child;
  final double? width;
  final int? flex;

  const _Cell({required this.child, this.width, this.flex});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 52),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.bodySmall,
        child: child,
      ),
    );

    if (flex != null) {
      return Expanded(flex: flex!, child: content);
    }

    return content;
  }
}
