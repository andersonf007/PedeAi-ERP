import 'package:flutter/material.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/controller/vendaController.dart';
import 'package:pedeai/theme/color_tokens.dart'; // BrandColors para status

class ListVendasPage extends StatefulWidget {
  const ListVendasPage({super.key});

  @override
  State<ListVendasPage> createState() => _ListVendasPageState();
}

class _ListVendasPageState extends State<ListVendasPage> {
  final _ctrl = VendaController();
  final _search = TextEditingController();

  bool _loading = true;
  String? _error;
  DateTimeRange? _range;

  // Vendas normalizadas como Map<String, dynamic>
  List<Map<String, dynamic>> _vendas = [];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final inicio = _range?.start;
      final fim = _range?.end;

      // implemente listarVendasResumo no controller retornando List<Map<String,dynamic>>
      final lista = await _ctrl.listarVendasResumo(inicio: inicio, fim: fim);

      final parsed = <Map<String, dynamic>>[];
      for (final v in lista) {
        if (v is Map) parsed.add(Map<String, dynamic>.from(v));
      }

      setState(() {
        _vendas = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar vendas: $e';
        _loading = false;
      });
    }
  }

  // --------- Filtros em memória ---------
  List<Map<String, dynamic>> get _filtradas {
    final q = _search.text.trim().toLowerCase();

    bool matchText(Map<String, dynamic> v) {
      final num = '${v['numero'] ?? v['id'] ?? ''}'.toLowerCase();
      final cli = '${v['cliente'] ?? v['nome_cliente'] ?? ''}'.toLowerCase();
      final status = '${v['status'] ?? v['situacao'] ?? ''}'.toLowerCase();
      return q.isEmpty || num.contains(q) || cli.contains(q) || status.contains(q);
    }

    bool matchRange(Map<String, dynamic> v) {
      if (_range == null) return true;
      final d = _parseDate(
        v['data'] ??
            v['data_venda'] ??
            v['created_at'] ??
            v['data_fechamento'] ??
            v['data_abertura'],
      );
      if (d == null) return true;
      final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
      final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59);
      return d.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          d.isBefore(end.add(const Duration(milliseconds: 1)));
    }

    return _vendas.where((v) => matchText(v) && matchRange(v)).toList();
  }

  // --------- KPIs ---------
  int get _qtdVendas => _filtradas.length;
  double get _faturado => _filtradas.fold<double>(0, (s, v) {
        final val = (v['total'] ?? v['valor_total'] ?? 0).toString();
        return s + (double.tryParse(val) ?? 0.0);
      });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Vendas', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Período',
            icon: Icon(Icons.date_range, color: cs.onSurface),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
                initialDateRange: _range ??
                    DateTimeRange(
                      start: DateTime(now.year, now.month, now.day),
                      end: DateTime(now.year, now.month, now.day),
                    ),
                saveText: 'Aplicar',
              );
              if (picked != null) {
                setState(() => _range = picked);
                _load();
              }
            },
          ),
          IconButton(
            tooltip: 'Atualizar',
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: _load,
          ),
        ],
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar: AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: cs.error)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), // espaço p/ CTA
                          children: [
                            Row(
                              children: [
                                Expanded(child: _SummaryTile(label: 'Vendas', value: '$_qtdVendas')),
                                const SizedBox(width: 12),
                                Expanded(child: _SummaryTile(label: 'Faturado', value: _brCurrency(_faturado))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _search,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por nº, cliente ou status',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (_filtradas.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Center(
                                  child: Text('Nenhuma venda encontrada', style: TextStyle(color: cs.onSurface.withValues(alpha: .7))),
                                ),
                              )
                            else
                              ..._filtradas.map(
                                (v) => _VendaTile(
                                  venda: v,
                                  onTap: () {
                                    // Registrar rota: '/venda-detalhe'
                                    // Navigator.pushNamed(context, '/venda-detalhe', arguments: v);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
          ),

          // CTA fixo — padrão Produtos
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushNamed(context, '/pdv'),
                child: const Text('Nova venda'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helpers ----------
  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    final s = raw.toString();
    try {
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  String _brCurrency(double v) => 'R\$ ${v.toStringAsFixed(2)}';
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bg = Color.alphaBlend(cs.primary.withValues(alpha: .08), cs.surface);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withValues(alpha: .10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: .75))),
          const SizedBox(height: 8),
          Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _VendaTile extends StatelessWidget {
  const _VendaTile({required this.venda, required this.onTap});
  final Map<String, dynamic> venda;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final border = cs.onSurface.withValues(alpha: .10);

    final id = venda['numero'] ?? venda['id'] ?? '—';
    final dt = _fmtDateTime(venda['data'] ?? venda['data_venda']);
    final cliente = venda['cliente'] ?? venda['nome_cliente'] ?? '—';
    final total = (double.tryParse('${venda['total'] ?? venda['valor_total'] ?? 0}') ?? 0.0);
    final itens = venda['qtd_itens'] ?? (venda['itens'] is List ? (venda['itens'] as List).length : null);
    final statusRaw = (venda['status'] ?? venda['situacao'] ?? '').toString();

    final status = statusRaw.isEmpty ? 'Pendente' : statusRaw;
    final statusColor = _statusColor(status);

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
            // bolinha de status
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            // textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // linha 1: Nº + Data
                  Row(
                    children: [
                      Text('#$id', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                      const SizedBox(width: 8),
                      Text('• $dt', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: .70))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // linha 2: Cliente + itens + status chip
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('Cliente: $cliente', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: .75))),
                      if (itens != null) Text('• $itens itens', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: .75))),
                      _StatusChip(text: status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // total
            Text('R\$ ${total.toStringAsFixed(2)}', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pago') || s.contains('final') || s.contains('fech')) return BrandColors.success700; // verde
    if (s.contains('pend') || s.contains('abert')) return BrandColors.warning700; // laranja
    if (s.contains('cancel')) return Colors.redAccent;
    return Colors.blueGrey;
  }

  String _fmtDateTime(dynamic raw) {
    if (raw == null) return '—';
    DateTime? d;
    if (raw is DateTime) {
      d = raw;
    } else {
      d = DateTime.tryParse(raw.toString());
    }
    if (d == null) return raw.toString();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  const _StatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
