import 'package:collection_app/core/enum/collection_status.dart';
  // Modelo principal do item da colecao.
class CollectionModel {
  final int? id;
  final String nome;
  final String? imagePath;
  final String descricao;
  final String localArmazenamento;
  final double valorCompra;
  final double valorVenda;
  final CollectionStatus status;
  final DateTime criadoEm;
  final bool isActive;
  final CollectionEmprestarModel? emprestar;

  CollectionModel({
    this.id,
    required this.nome,
    this.imagePath,
    required this.descricao,
    required this.localArmazenamento,
    required this.valorCompra,
    required this.valorVenda,
    this.status = CollectionStatus.acervo,
    DateTime? criadoEm,
    this.isActive = true,
    this.emprestar,
  }) : criadoEm = criadoEm ?? DateTime.now();

  // Permite atualizacao parcial dos dados.

  CollectionModel copyWith({
    int? id,
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
    return CollectionModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      imagePath: imagePath ?? this.imagePath,
      descricao: descricao ?? this.descricao,
      localArmazenamento: localArmazenamento ?? this.localArmazenamento,
      valorCompra: valorCompra ?? this.valorCompra,
      valorVenda: valorVenda ?? this.valorVenda,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
      isActive: isActive ?? this.isActive,
      emprestar: emprestar ?? this.emprestar,
    );
  }

  // Converte o objeto para Map para armazenamento no SQLite.

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'imagePath': imagePath,
      'descricao': descricao,
      'localArmazenamento': localArmazenamento,
      'valorCompra': valorCompra,
      'valorVenda': valorVenda,
      'status': status.name,
      'criadoEm': criadoEm.toIso8601String(),
      'isActive': isActive,
      'emprestar': emprestar?.toMap(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  // Cria um objeto a partir do Map recuperado do SQLite.
  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      descricao: map['descricao'] as String? ?? '',
      localArmazenamento: map['localArmazenamento'] as String? ?? '',
      valorCompra: (map['valorCompra'] as num?)?.toDouble() ?? 0,
      valorVenda: (map['valorVenda'] as num?)?.toDouble() ?? 0,
      status: _statusFromMap(map['status']),
      criadoEm:
          DateTime.tryParse(map['criadoEm'] as String? ?? '') ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      emprestar: CollectionEmprestarModel.fromNullableMap(
        map['emprestar'] ?? map['loan'],
      ),
    );
  }

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel.fromMap(json);
  }

  static CollectionStatus _statusFromMap(Object? value) {
    if (value is int && value >= 0 && value < CollectionStatus.values.length) {
      return CollectionStatus.values[value];
    }

    if (value is String) {
      for (final status in CollectionStatus.values) {
        if (status.name == value) {
          return status;
        }
      }
    }

    return CollectionStatus.acervo;
  }
}
// Dados opcionais de emprestimo/troca
class CollectionEmprestarModel {
  final String nome;
  final String endereco;
  final String dataEmprestimo;
  final String dataDevolucao;
  final String? imagePathEntrada;
  final String? imagePathSaida;
  final String observacoesEntrada;
  final String observacoesSaida;

  const CollectionEmprestarModel({
    required this.nome,
    required this.endereco,
    required this.dataEmprestimo,
    required this.dataDevolucao,
    this.imagePathEntrada,
    this.imagePathSaida,
    required this.observacoesEntrada,
    required this.observacoesSaida,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'dataEmprestimo': dataEmprestimo,
      'dataDevolucao': dataDevolucao,
      'imagePathEntrada': imagePathEntrada,
      'imagePathSaida': imagePathSaida,
      'observacoesEntrada': observacoesEntrada,
      'observacoesSaida': observacoesSaida,
    };
  }

  factory CollectionEmprestarModel.fromMap(Map<String, dynamic> map) {
    return CollectionEmprestarModel(
      nome: map['nome'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      dataEmprestimo: map['dataEmprestimo'] as String? ?? '',
      dataDevolucao: map['dataDevolucao'] as String? ?? '',
      imagePathEntrada: map['imagePathEntrada'] as String?,
      imagePathSaida: map['imagePathSaida'] as String?,
      observacoesEntrada: map['observacoesEntrada'] as String? ?? '',
      observacoesSaida: map['observacoesSaida'] as String? ?? '',
    );
  }

  static CollectionEmprestarModel? fromNullableMap(Object? value) {
    if (value is! Map) {
      return null;
    }

    return CollectionEmprestarModel.fromMap(Map<String, dynamic>.from(value));
  }
}
