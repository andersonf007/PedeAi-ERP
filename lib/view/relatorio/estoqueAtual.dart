import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstoqueAtualRelatorioPdf {
  static Future<void> exportar({required BuildContext context, List<Produto>? produtos}) async {
    try {
      // Se não vier a lista, busca do controller
      final _produtoController = Produtocontroller();
      final listaProdutos = produtos ?? await _produtoController.listarProdutos();

      // 1) Carrega fontes com suporte a acentos
      final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

      // 2) Monta o documento
      final doc = pw.Document();
      final theme = pw.ThemeData.withFont(base: fontRegular, bold: fontBold);

      // Helpers locais
      String money(num v) => 'R\$ ${v.toStringAsFixed(2)}';
      String numFmt(num v) {
        final i = v.roundToDouble();
        return ((v - i).abs() < 0.001) ? i.toStringAsFixed(0) : v.toStringAsFixed(2);
      }

      final qtdTotal = listaProdutos.fold<double>(0, (s, p) => s + (p.estoque ?? 0).toDouble());
      final valorTotal = listaProdutos.fold<double>(0, (s, p) {
        final qtd = (p.estoque ?? 0).toDouble();
        final custoOuVenda = (p.precoCusto ?? p.preco ?? 0).toDouble();
        return s + qtd * custoOuVenda;
      });

      // Tabela de itens
      final headers = ['Código', 'Produto', 'Qtd', 'Custo', 'Venda', 'Subtotal'];
      final dataRows = listaProdutos.map((p) {
        final qtd = (p.estoque ?? 0).toDouble();
        final custo = (p.precoCusto ?? 0).toDouble();
        final venda = (p.preco ?? 0).toDouble();
        final subtotal = qtd * (custo == 0 ? venda : custo);
        return [(p.codigo ?? '—'), (p.descricao ?? '—'), numFmt(qtd), money(custo), money(venda), money(subtotal)];
      }).toList();

      // Quem é a empresa?
      final empresa = await EmpresaController().getEmpresaFromSharedPreferences();
      final empresaNome = (empresa?.fantasia?.trim().isNotEmpty ?? false) ? empresa!.fantasia! : (empresa?.schema ?? 'Empresa');

      // Quem está emitindo?
      final supaUser = Supabase.instance.client.auth.currentUser;
      final emissor = (supaUser?.userMetadata?['fantasia'] as String?) ?? (supaUser?.userMetadata?['razao'] as String?) ?? (supaUser?.email) ?? (supaUser?.id) ?? '—';

      final agora = DateTime.now();

      doc.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),

          // TÍTULO COM EMPRESA
          header: (ctx) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(empresaNome, style: pw.TextStyle(font: fontBold, fontSize: 14)),
                  pw.SizedBox(height: 2),
                  pw.Text('Relatório de Estoque', style: pw.TextStyle(font: fontBold, fontSize: 18)),
                ],
              ),
              pw.Text(_formatDateTimePdf(agora), style: const pw.TextStyle(fontSize: 10)),
            ],
          ),

          // RODAPÉ COM EMISSOR + PAGINAÇÃO
          footer: (ctx) => pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(width: .5, color: PdfColors.grey400)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Emitido por: $emissor', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Página ${ctx.pageNumber}/${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),

          // CONTEÚDO
          build: (ctx) => [
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Quantidade total: ${numFmt(qtdTotal)}', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Valor total: ${money(valorTotal)}',
                    style: pw.TextStyle(fontSize: 12, color: valorTotal < 0 ? PdfColors.red : PdfColors.black, font: fontBold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            // Tabela
            pw.Table.fromTextArray(
              headers: headers,
              data: dataRows,
              headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.brown700),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FixedColumnWidth(62), // Código
                1: const pw.FlexColumnWidth(), // Produto
                2: const pw.FixedColumnWidth(45), // Qtd
                3: const pw.FixedColumnWidth(60), // Custo
                4: const pw.FixedColumnWidth(60), // Venda
                5: const pw.FixedColumnWidth(68), // Subtotal
              },
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
            ),
          ],
        ),
      );
      final bytes = await doc.save();
      final fileName = 'estoque_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        // força DOWNLOAD no navegador
        await FileSaver.instance.saveFile(name: fileName, bytes: bytes, fileExtension: 'pdf', mimeType: MimeType.pdf);
      } else {
        // salva em um local acessível do app e abre o arquivo
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao exportar: $e', style: TextStyle(color: cs.onPrimary)),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  static String _formatDateTimePdf(DateTime d) => '${_2(d.day)}/${_2(d.month)}/${d.year} ${_2(d.hour)}:${_2(d.minute)}';
  static String _2(int n) => n.toString().padLeft(2, '0');
}
