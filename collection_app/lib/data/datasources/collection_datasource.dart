import 'dart:convert';

import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CollectionDataSource {
  static const String databaseName = 'collection_app.db';
  static const String tableName = 'collections';

  static Database? _database;
 // Abre o banco apenas uma vez e reutiliza a mesma instancia.
  Future<Database> get _db async {
    _database ??= await _openDatabase();
    return _database!;
  }

  static void initDatabaseFactory() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<void> add(CollectionModel collection) async {
    final db = await _db;
    await db.insert(
      tableName,
      _toRow(collection),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CollectionModel>> getAll() async {
    final db = await _db;
    final rows = await db.query(tableName, orderBy: 'id ASC');

    return rows.map(_fromRow).toList();
  }

  Future<void> update(int index, CollectionModel collection) async {
    final id = collection.id ?? index;
    final db = await _db;
    await db.update(
      tableName,
      _toRow(collection.copyWith(id: id)),
      where: 'id = ?',
      whereArgs: [id],
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
  }) async {
    final collection = await _getById(id);

    if (collection == null) {
      return;
    }

    await _updateCollection(
      collection.copyWith(
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
      ),
    );
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
  }) async {
    await updatePartialById(
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

  Future<void> deactivate(int index) async {
    await updatePartialById(index, isActive: false);
  }

  Future<void> deactivateById(int id) async {
    await updatePartialById(id, isActive: false);
  }

  Future<void> activate(int index) async {
    await updatePartialById(index, isActive: true);
  }

  Future<void> delete(int index) async {
    final db = await _db;
    await db.delete(tableName, where: 'id = ?', whereArgs: [index]);
  }

  Future<void> clear() async {
    final db = await _db;
    await db.delete(tableName);
  }

  Future<int> get nextId async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT MAX(id) AS max_id FROM $tableName');
    final maxId = rows.first['max_id'] as int?;
    return (maxId ?? 0) + 1;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await databaseFactory.getDatabasesPath();
    final databasePath = p.join(databasesPath, databaseName);

    return databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableName (
              id INTEGER PRIMARY KEY,
              payload TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }
// Converte o model para o formato persistido no SQLite.
  Map<String, Object?> _toRow(CollectionModel collection) {
    final id = collection.id;

    if (id == null) {
      throw ArgumentError('CollectionModel.id nao pode ser nulo no SQLite.');
    }

    return {'id': id, 'payload': jsonEncode(collection.toJson())};
  }
// Reconstroi o model a partir do JSON salvo no payload.
  CollectionModel _fromRow(Map<String, Object?> row) {
    final payload = jsonDecode(row['payload'] as String);
    final collection = CollectionModel.fromJson(
      Map<String, dynamic>.from(payload as Map),
    );

    return collection.copyWith(id: row['id'] as int);
  }

  Future<CollectionModel?> _getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _fromRow(rows.first);
  }

  Future<void> _updateCollection(CollectionModel collection) async {
    final db = await _db;
    await db.update(
      tableName,
      _toRow(collection),
      where: 'id = ?',
      whereArgs: [collection.id],
    );
  }
}
