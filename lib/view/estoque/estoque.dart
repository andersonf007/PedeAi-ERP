import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:file_saver/file_saver.dart';

//  salvar arquivo no mobile/desktop:
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
//---------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedeai/controller/estoqueController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cadastrarEstoque.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});
  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final _produtoController = Produtocontroller();
  final _search = TextEditingController();

  bool _loading = true;
  String? _error;
  List<Produto> _produtos = [];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final list = await _produtoController.listarProdutos();
      setState(() {
        _produtos = List.from(list);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar estoque: $e';
        _loading = false;
      });
    }
  }

  double get _qtdTotal =>
      _produtos.fold<double>(0, (s, p) => s + (p.estoque ?? 0).toDouble());

  double get _valorTotal {
    return _produtos.fold<double>(0, (s, p) {
      final qtd = (p.estoque ?? 0).toDouble();
      final custoOuVenda = (p.precoCusto ?? p.preco ?? 0).toDouble();
      return s + qtd * custoOuVenda;
    });
  }

  List<Produto> get _filtrados {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _produtos;
    return _produtos.where((p) {
      final n = (p.descricao ?? '').toLowerCase();
      final c = (p.codigo ?? '').toLowerCase();
      return n.contains(q) || c.contains(q);
    }).toList();
  }

  String _brNum(double v, {int frac = 2}) {
    // 1234.5 -> 1.234,50
    final s = v.toStringAsFixed(frac);
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return '$intPart,${parts.length > 1 ? parts[1] : '00'}';
  }

  Future<void> _exportarEstoquePdf() async {
    try {
      // 1) Carrega fontes com suporte a acentos
      final fontRegular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
      );
      final fontBold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
      );

      // 2) Monta o documento
      final doc = pw.Document();
      final theme = pw.ThemeData.withFont(base: fontRegular, bold: fontBold);

      // Helpers locais
      String money(num v) => 'R\$ ${v.toStringAsFixed(2)}';
      String numFmt(num v) {
        final i = v.roundToDouble();
        return ((v - i).abs() < 0.001)
            ? i.toStringAsFixed(0)
            : v.toStringAsFixed(2);
      }

      final qtdTotal = _produtos.fold<double>(
        0,
        (s, p) => s + (p.estoque ?? 0).toDouble(),
      );
      final valorTotal = _produtos.fold<double>(0, (s, p) {
        final qtd = (p.estoque ?? 0).toDouble();
        final custoOuVenda = (p.precoCusto ?? p.preco ?? 0).toDouble();
        return s + qtd * custoOuVenda;
      });

      // Tabela de itens
      final headers = [
        'Código',
        'Produto',
        'Qtd',
        'Custo',
        'Venda',
        'Subtotal',
      ];
      final dataRows = _produtos.map((p) {
        final qtd = (p.estoque ?? 0).toDouble();
        final custo = (p.precoCusto ?? 0).toDouble();
        final venda = (p.preco ?? 0).toDouble();
        final subtotal = qtd * (custo == 0 ? venda : custo);
        return [
          (p.codigo ?? '—'),
          (p.descricao ?? '—'),
          numFmt(qtd),
          money(custo),
          money(venda),
          money(subtotal),
        ];
      }).toList();

      // Quem é a empresa?
      final empresa = await EmpresaController()
          .getEmpresaFromSharedPreferences();
      final empresaNome = (empresa?.fantasia?.trim().isNotEmpty ?? false)
          ? empresa!.fantasia!
          : (empresa?.schema ?? 'Empresa');

      // Quem está emitindo?
      final supaUser = Supabase.instance.client.auth.currentUser;
      final emissor =
          (supaUser?.userMetadata?['fantasia'] as String?) ??
          (supaUser?.userMetadata?['razao'] as String?) ??
          (supaUser?.email) ??
          (supaUser?.id) ??
          '—';

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
                  pw.Text(
                    empresaNome,
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Relatório de Estoque',
                    style: pw.TextStyle(font: fontBold, fontSize: 18),
                  ),
                ],
              ),
              pw.Text(
                _formatDateTimePdf(agora),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),

          // RODAPÉ COM EMISSOR + PAGINAÇÃO
          footer: (ctx) => pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(width: .5, color: PdfColors.grey400),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Emitido por: $emissor',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Página ${ctx.pageNumber}/${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),

          // CONTEÚDO
          build: (ctx) => [
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Quantidade total: ${numFmt(qtdTotal)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Valor total: ${money(valorTotal)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: valorTotal < 0 ? PdfColors.red : PdfColors.black,
                      font: fontBold,
                    ),
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
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.brown700,
              ),
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
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
            ),
          ],
        ),
      );
      final bytes = await doc.save();
      final fileName = 'estoque_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        // força DOWNLOAD no navegador
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
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
          content: Text(
            'Falha ao exportar: $e',
            style: TextStyle(color: cs.onPrimary),
          ),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  // Pequeno formatador de data para o cabeçalho do PDF
  String _formatDateTimePdf(DateTime d) =>
      '${_2(d.day)}/${_2(d.month)}/${d.year} ${_2(d.hour)}:${_2(d.minute)}';
  String _2(int n) => n.toString().padLeft(2, '0');
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Estoque'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Exportar',
            icon: Icon(Icons.file_download_outlined, color: cs.onSurface),
            onPressed: _exportarEstoquePdf,
          ),
        ],
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar: AppNavBar(
        currentRoute: ModalRoute.of(context)?.settings.name,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.error),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: 'Quantidade total em estoque',
                          value: _formatNumber(_qtdTotal),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Valor total em estoque',
                          value: _formatCurrency(_valorTotal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      hintText: 'Buscar produtos',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._filtrados.map(
                    (p) => _ProdutoTile(
                      produto: p,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EstoqueDetalhePage(produto: p),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_filtrados.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'Nenhum produto encontrado.',
                          style: TextStyle(color: cs.onSurface.withOpacity(.7)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _formatCurrency(double v) => 'R\$ ${v.toStringAsFixed(2)}';

  String _formatNumber(double v) {
    final i = v.roundToDouble();
    if ((v - i).abs() < 0.001) return i.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bg = Color.alphaBlend(cs.primary.withOpacity(.08), cs.surface);

    // vermelho quando o valor textual começa com "R$ -" (saldo negativo)
    final isNegative = value.contains('R\$ -');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isNegative ? Colors.redAccent : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProdutoTile extends StatelessWidget {
  const _ProdutoTile({required this.produto, required this.onTap});
  final Produto produto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final border = cs.onSurface.withOpacity(.10);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.descricao ?? '—',
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subline(produto),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(.70),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Thumb(imageUrl: produto.image_url),
          ],
        ),
      ),
    );
  }

  String _subline(Produto p) {
    final cod = (p.codigo ?? '—');
    final est = (p.estoque ?? 0).toString();
    final custo = (p.precoCusto ?? 0).toStringAsFixed(2);
    final venda = (p.preco ?? 0).toStringAsFixed(2);
    final validade = (p.validade ?? '').isEmpty ? '—' : p.validade!;
    return 'Cód. $cod  |  Estoque: $est  \nCusto: R\$ $custo     |  Venda: R\$ $venda';
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 78,
        height: 78,
        color: cs.surface,
        child: (imageUrl ?? '').isEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(.05),
                  border: Border.all(color: cs.onSurface.withOpacity(.10)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.image, color: cs.onSurface.withOpacity(.45)),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.onSurface.withOpacity(.05),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image,
                    color: cs.onSurface.withOpacity(.45),
                  ),
                ),
              ),
      ),
    );
  }
}
