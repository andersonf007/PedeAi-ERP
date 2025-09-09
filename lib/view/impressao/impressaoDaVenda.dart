import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pedeai/model/itemCarrinho.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class ImpressaoDaVendaPage extends StatelessWidget {
  final int idVenda;
  final List<ItemCarrinho> carrinho;
  final double subtotal;
  final double desconto;
  final double total;
  final List<Map<String, dynamic>> pagamentos;
  final double troco;
  final Map<String, dynamic> dadosVenda;

  const ImpressaoDaVendaPage({
    super.key,
    required this.idVenda,
    required this.dadosVenda,
    required this.carrinho,
    required this.subtotal,
    required this.desconto,
    required this.total,
    required this.pagamentos,
    required this.troco,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          'Impressão do Pedido',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/pdv', (route) => false),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: cs.onSurface),
            onPressed: () async {
              final pdfFile = await _gerarPdfCupom(context);
              await Share.shareXFiles(
                [XFile(pdfFile.path)],
                text: 'Cupom do pedido $idVenda',
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<InlineSpan>>(
        future: _gerarCupomRich(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            );
          }
          return Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                width: double.infinity,
                child: Card(
                  elevation: 1,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                        children: snapshot.data!,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<InlineSpan>> _gerarCupomRich(BuildContext context) async {
    final empresa = await EmpresaController().getEmpresaFromSharedPreferences();
    final width = MediaQuery.of(context).size.width;
    // Aproximação: cada caractere monospace ~10px (ajuste se necessário)
    final charsPerLine = ((width - 32) / 10).floor().clamp(28, 60);

    List<InlineSpan> spans = [];

    String linhaTracejada() => '-' * charsPerLine;

    spans.add(TextSpan(
        text: _center('*** NÃO É DOCUMENTO FISCAL ***',
                width: charsPerLine) +
            '\n'));
    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    if (empresa != null) {
      spans.add(TextSpan(text: '${empresa.fantasia ?? ''}\n'));
      spans.add(TextSpan(text: '${empresa.cnpj ?? ''}\n'));
      spans.add(TextSpan(
          text:
              '${empresa.logradouro ?? ''}, ${empresa.numero ?? ''}\n'));
      spans.add(TextSpan(
          text:
              '${empresa.bairro ?? ''} - ${empresa.municipio ?? ''} - ${empresa.uf ?? ''}\n'));
      if ((empresa.telefone ?? '').isNotEmpty) {
        spans.add(TextSpan(text: 'Fone: ${empresa.telefone}\n'));
      }
    }
    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    spans.add(TextSpan(text: 'Pedido: $idVenda\n'));
    spans.add(
        TextSpan(text: 'Data: ${_formatarDataHora(DateTime.now())}\n'));
    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    spans.add(TextSpan(
        text: _linha(
                ['Descrição', 'Qtd', 'V.Unit', 'Total'],
                _colWidths(charsPerLine)) +
            '\n'));
    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    for (final item in carrinho) {
      final nome = (item.produto.descricao ?? '').length >
              _colWidths(charsPerLine)[0]
          ? (item.produto.descricao ?? '')
              .substring(0, _colWidths(charsPerLine)[0])
          : (item.produto.descricao ?? '');
      final qtd = item.quantidade.toStringAsFixed(2);
      final vlUnit = (item.produto.preco ?? 0)
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      final totalItem = ((item.produto.preco ?? 0) * item.quantidade)
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      spans.add(TextSpan(
          text: _linha([nome, qtd, vlUnit, totalItem],
                  _colWidths(charsPerLine)) +
              '\n'));
    }

    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    // Subtotal em negrito
    spans.add(
      TextSpan(
        text: _linha(
                ['SubTotal:', '', '', _real(subtotal)],
                _colWidths(charsPerLine)) +
            '\n',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    spans.add(TextSpan(
        text: _linha(['Desconto:', '', '', _real(desconto)],
                _colWidths(charsPerLine)) +
            '\n'));
    // Total em negrito
    spans.add(
      TextSpan(
        text: _linha(['Total:', '', '', _real(total)],
                _colWidths(charsPerLine)) +
            '\n',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    spans.add(const TextSpan(text: 'Pagamentos:\n'));
    for (final pag in pagamentos) {
      final nome = (pag['forma']?.nome).toString();
      final valor =
          pag['valor'] != null ? _real(pag['valor']) : '';
      spans.add(TextSpan(
          text: _linha([nome, '', '', valor], _colWidths(charsPerLine)) +
              '\n'));
    }
    spans.add(TextSpan(
        text: _linha(['Troco:', '', '', _real(troco)],
                _colWidths(charsPerLine)) +
            '\n'));

    spans.add(TextSpan(text: linhaTracejada() + '\n'));
    spans.add(TextSpan(
        text: _center('PedeAi ERP', width: charsPerLine) + '\n'));
    spans.add(TextSpan(
        text:
            _center('Obrigado, volte sempre!', width: charsPerLine) + '\n'));
    spans.add(TextSpan(text: linhaTracejada() + '\n'));

    return spans;
  }

  List<int> _colWidths(int charsPerLine) {
    // Proporção para 4 colunas: [Descrição, Qtd, V.Unit, Total]
    final desc = (charsPerLine * 0.42).floor();
    final qtd = (charsPerLine * 0.13).floor();
    final vunit = (charsPerLine * 0.21).floor();
    final total = charsPerLine - desc - qtd - vunit;
    return [desc, qtd, vunit, total];
  }

  String _center(String text, {int width = 38}) {
    final len = text.length;
    if (len >= width) return text;
    final pad = ((width - len) / 2).floor();
    return ' ' * pad + text;
  }

  String _linha(List<String> cols, List<int> ws) {
    String linha = '';
    for (var i = 0; i < ws.length && i < cols.length; i++) {
      final col = cols[i];
      if (i == 0) {
        linha += col.padRight(ws[i]);
      } else {
        linha += col.padLeft(ws[i]);
      }
    }
    return linha;
  }

  String _real(num? valor) {
    if (valor == null) return '';
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarDataHora(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<File> _gerarPdfCupom(BuildContext context) async {
    final spans = await _gerarCupomRich(context);
    final textoCupom = spans.map((e) => e.toPlainText()).join();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              color: PdfColors.white,
              child: pw.Text(
                textoCupom,
                style: pw.TextStyle(
                  font: pw.Font.courier(),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cupom_pedido_${idVenda}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
