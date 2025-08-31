import 'package:flutter/material.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/controller/vendaController.dart';
import 'package:pedeai/theme/color_tokens.dart';

class VendaDetalhePage extends StatefulWidget {
  const VendaDetalhePage({Key? key}) : super(key: key);

  @override
  State<VendaDetalhePage> createState() => _VendaDetalhePageState();
}

class _VendaDetalhePageState extends State<VendaDetalhePage> {
  final _ctrl = VendaController();

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _venda; // campos: id/numero, cliente, subtotal, desconto, total, status, data_venda...
  List<Map<String, dynamic>> _itens = [];
  List<Map<String, dynamic>> _pagamentos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // recebe: Map (resumo) OU id/numero
    final args = ModalRoute.of(context)?.settings.arguments;
    _load(args);
  }

  Future<void> _load(dynamic args) async {
    if (_loading == false && _venda != null) return;
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      Map<String, dynamic>? vendaResumo;
      dynamic id;

      if (args is Map<String, dynamic>) {
        vendaResumo = args;
        id = vendaResumo['id'] ?? vendaResumo['numero'];
      } else {
        id = args; // pode ser int/string
      }

      // Se o resumo já veio com itens/pagamentos, usa; senão busca no controller.
      if (vendaResumo != null &&
          (vendaResumo['itens'] is List || vendaResumo['pagamentos'] is List)) {
        _venda = vendaResumo;
        _itens = List<Map<String, dynamic>>.from(vendaResumo['itens'] ?? const []);
        _pagamentos = List<Map<String, dynamic>>.from(vendaResumo['pagamentos'] ?? const []);
      } else {
        final detalhe = await _ctrl.listarVendaDetalhe(id: id);
        _venda = Map<String, dynamic>.from(detalhe['venda'] ?? {});
        _itens = List<Map<String, dynamic>>.from(detalhe['itens'] ?? const []);
        _pagamentos = List<Map<String, dynamic>>.from(detalhe['pagamentos'] ?? const []);
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar venda: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final id = _venda?['numero'] ?? _venda?['id'] ?? '—';
    final dt = _fmtDateTime(_venda?['data'] ?? _venda?['data_venda']);
    final cliente = _venda?['cliente'] ?? _venda?['nome_cliente'] ?? '—';
    final statusRaw = (_venda?['status'] ?? _venda?['situacao'] ?? '').toString();
    final status = statusRaw.isEmpty ? 'Pendente' : statusRaw;

    final subtotal = _toDouble(_venda?['subtotal'] ?? _venda?['valor_subtotal']);
    final desconto = _toDouble(_venda?['desconto'] ?? _venda?['valor_desconto']);
    final total = _toDouble(_venda?['total'] ?? _venda?['valor_total']);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: cs.onSurface),
        title: Text('Venda #$id', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: () => _load(ModalRoute.of(context)?.settings.arguments),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar: AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: cs.error)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _load(ModalRoute.of(context)?.settings.arguments),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    children: [
                      // Header resumo
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(cs.primary.withOpacity(.08), cs.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.onSurface.withOpacity(.10)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _StatusDot(text: status),
                                const SizedBox(width: 8),
                                Text('• $dt', style: TextStyle(color: cs.onSurface.withOpacity(.75))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Cliente: $cliente',
                                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Total: ${_brCurrency(total)}',
                                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Resumo financeiro
                      _CardSection(
                        title: 'Resumo',
                        child: Column(
                          children: [
                            _kv('Subtotal', _brCurrency(subtotal), cs),
                            _kv('Desconto', '- ${_brCurrency(desconto)}', cs, dim: true),
                            const Divider(height: 20),
                            _kv('Total', _brCurrency(total), cs, bold: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Pagamentos
                      _CardSection(
                        title: 'Pagamentos',
                        child: _pagamentos.isEmpty
                            ? Text('Nenhuma forma de pagamento registrada.',
                                style: TextStyle(color: cs.onSurface.withOpacity(.70)))
                            : Column(
                                children: [
                                  ..._pagamentos.map((p) {
                                    final nome = p['forma']?['nome'] ?? p['forma_nome'] ?? 'Forma';
                                    final valor = _toDouble(p['valor']);
                                    final troco = _toDouble(p['troco']);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text('$nome',
                                                style: TextStyle(color: cs.onSurface.withOpacity(.90))),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(_brCurrency(valor),
                                                  style: TextStyle(
                                                      color: cs.onSurface, fontWeight: FontWeight.w700)),
                                              if (troco > 0)
                                                Text('Troco ${_brCurrency(troco)}',
                                                    style: TextStyle(
                                                        color: BrandColors.success700,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Itens
                      _CardSection(
                        title: 'Itens',
                        child: _itens.isEmpty
                            ? Text('Nenhum item na venda.',
                                style: TextStyle(color: cs.onSurface.withOpacity(.70)))
                            : Column(
                                children: _itens.map((it) {
                                  final nome = it['descricao'] ?? it['produto'] ?? '—';
                                  final qtd = _toDouble(it['quantidade']).toStringAsFixed(0);
                                  final unit = _brCurrency(_toDouble(it['preco_unitario'] ?? it['unitario']));
                                  final tot = _brCurrency(_toDouble(it['preco_total'] ?? it['total']));
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(nome,
                                                  style: TextStyle(
                                                      color: cs.onSurface,
                                                      fontWeight: FontWeight.w700)),
                                              const SizedBox(height: 2),
                                              Text('$qtd x $unit',
                                                  style: TextStyle(
                                                      color: cs.onSurface.withOpacity(.70), fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(tot,
                                            style: TextStyle(
                                                color: cs.onSurface, fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),

                      const SizedBox(height: 80), // respiro pro CTA
                    ],
                  ),
                ),

      // CTA fixo – iniciar outra venda
    
    );
  }

  // ---------- helpers ----------
  String _brCurrency(double v) => 'R\$ ${v.toStringAsFixed(2)}';

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
    }

  String _fmtDateTime(dynamic raw) {
    if (raw == null) return '—';
    DateTime? d;
    if (raw is DateTime) d = raw; else d = DateTime.tryParse(raw.toString());
    if (d == null) return raw.toString();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

// --- Widgets auxiliares
class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = text.toLowerCase();
    Color c;
    if (s.contains('pago') || s.contains('final') || s.contains('fech')) {
      c = BrandColors.success700;
    } else if (s.contains('pend') || s.contains('abert')) {
      c = BrandColors.warning700;
    } else if (s.contains('cancel')) {
      c = Colors.redAccent;
    } else {
      c = Colors.blueGrey;
    }

    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(999)),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

Widget _kv(String k, String v, ColorScheme cs, {bool bold = false, bool dim = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TextStyle(color: cs.onSurface.withOpacity(dim ? .70 : .90))),
        Text(
          v,
          style: TextStyle(
            color: dim ? cs.onSurface.withOpacity(.80) : cs.onSurface,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
