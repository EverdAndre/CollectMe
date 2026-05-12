import '../../core/enum/collectin_status.dart';

class CollectionModel {
  final int? id;
  final String nome;
  final String? imagePth;
  final String descricao;
  final String localarmazenamento;
  final double valorcompra;
  final double valorvenda;
  final CollectionStatus status;
  DateTime? criadoEm;
  bool? isActive;

  CollectionModel({
    this.id,
    required this.nome,
    this.imagePth,
    required this.descricao,
    required this.localarmazenamento,
    required this.valorcompra,
    required this.valorvenda,
    required this.status,
    this.criadoEm,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'imagePth': imagePth,
      'descricao': descricao,
      'localarmazenamento': localarmazenamento,
      'valorcompra': valorcompra,
      'valorvenda': valorvenda,
      'status': status.index,
      'criadoEm': criadoEm?.toIso8601String(),
      'isActive': isActive == true ? 1 : 0,
    };
  }

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'],
      nome: map['nome'],
      imagePth: map['imagePth'],
      descricao: map['descricao'],
      localarmazenamento: map['localarmazenamento'],
      valorcompra: map['valorcompra'],
      valorvenda: map['valorvenda'],
      status: CollectionStatus.values[map['status']],
      criadoEm: map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
      isActive: map['isActive'] == 1,
    );
  }
}
