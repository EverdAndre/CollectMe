import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/datasources/collection_datasource.dart';
import 'package:collection_app/data/models/collection_model.dart';

class CollectionRepository {
  final CollectionDataSource _dataSource;

  CollectionRepository(this._dataSource);

  // Camada de conexao entre as telas/controllers e o datasource SQLite.
  Future<List<CollectionModel>> getAll() {
    return _dataSource.getAll();
  }

  Future<void> add(CollectionModel collection) {
    return _dataSource.add(collection);
  }

  Future<void> updatePartial(
    int index, {
    String? nome,
    String? imagePath,
    String? descricao,
    String? localArmazenamento,
    double? valorCompra,
    double? valorVenda,
    CollectionStatus? status,
    DateTime? criadoEm,
    bool? isActive,
    CollectionEmprestarModel? emprestar,
  }) {
    return _dataSource.updatePartial(
      index,
      nome: nome,
      imagePath: imagePath,
      descricao: descricao,
      localArmazenamento: localArmazenamento,
      valorCompra: valorCompra,
      valorVenda: valorVenda,
      status: status,
      criadoEm: criadoEm,
      isActive: isActive,
      emprestar: emprestar,
    );
  }

  Future<void> updatePartialById(
    int id, {
    String? nome,
    String? imagePath,
    String? descricao,
    String? localArmazenamento,
    double? valorCompra,
    double? valorVenda,
    CollectionStatus? status,
    DateTime? criadoEm,
    bool? isActive,
    CollectionEmprestarModel? emprestar,
  }) {
    return _dataSource.updatePartialById(
      id,
      nome: nome,
      imagePath: imagePath,
      descricao: descricao,
      localArmazenamento: localArmazenamento,
      valorCompra: valorCompra,
      valorVenda: valorVenda,
      status: status,
      criadoEm: criadoEm,
      isActive: isActive,
      emprestar: emprestar,
    );
  }

  Future<void> deactivate(int index) {
    return _dataSource.deactivate(index);
  }

  Future<void> deactivateById(int id) {
    return _dataSource.deactivateById(id);
  }

  Future<void> activate(int index) {
    return _dataSource.activate(index);
  }

  Future<int> get nextId => _dataSource.nextId;
}
