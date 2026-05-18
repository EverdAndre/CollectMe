import 'dart:typed_data';

import 'package:collection_app/core/enum/collection_status.dart';
import 'package:collection_app/data/models/collection_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CollectionRelatorioService {
  CollectionRelatorioData buildData(List<CollectionModel> collections) {
    final activeItems = collections.where((item) => item.isActive).toList();

    return CollectionRelatorioData(
      totalItens: activeItems.length,
      valorEstimadoColecao: activeItems.fold(
        0,
        (total, item) => total + item.valorVenda,
      ),
      valorCustoColecao: activeItems.fold(
        0,
        (total, item) => total + item.valorCompra,
      ),
      quantidadeAcervo: activeItems
          .where((item) => item.status == CollectionStatus.acervo)
          .length,
      quantidadeEmprestados: activeItems
          .where((item) => item.status == CollectionStatus.emprestado)
          .length,
      quantidadeTroca: activeItems
          .where((item) => item.status == CollectionStatus.emprestado)
          .length,
    );
  }
    // Gera o PDF a partir da mesma lista carregada pelo repositorio.
  Future<Uint8List> buildPdf(
    List<CollectionModel> collections, {
    String title = 'Relatorio de Itens',
  }) async {
    final activeItems = collections.where((item) => item.isActive).toList();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            if (activeItems.isEmpty)
              pw.Text('Nenhum item selecionado.')
            else
              _itemsTable(activeItems),
          ];
        },
      ),
    );

    return doc.save();
  }
    // Envia o PDF gerado para o dialogo de impressao/compartilhamento.
  Future<void> printReport(
    List<CollectionModel> collections, {
    String title = 'Relatorio de Itens',
  }) {
    return Printing.layoutPdf(
      onLayout: (_) => buildPdf(collections, title: title),
    );
  }

  pw.Widget _itemsTable(List<CollectionModel> items) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      columnWidths: const {
        0: pw.FixedColumnWidth(28),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(),
        3: pw.FixedColumnWidth(56),
        4: pw.FixedColumnWidth(56),
        5: pw.FixedColumnWidth(62),
      },
      headers: const ['ID', 'Nome', 'Local', 'Compra', 'Venda', 'Status'],
      data: items.map((item) {
        return [
          '${item.id ?? ''}',
          item.nome,
          item.localArmazenamento,
          _formatMoney(item.valorCompra),
          _formatMoney(item.valorVenda),
          _statusLabel(item.status),
        ];
      }).toList(),
    );
  }

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
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
}

class CollectionRelatorioData {
  final int totalItens;
  final double valorEstimadoColecao;
  final double valorCustoColecao;
  final int quantidadeAcervo;
  final int quantidadeEmprestados;
  final int quantidadeTroca;

  const CollectionRelatorioData({
    required this.totalItens,
    required this.valorEstimadoColecao,
    required this.valorCustoColecao,
    required this.quantidadeAcervo,
    required this.quantidadeEmprestados,
    required this.quantidadeTroca,
  });
}
