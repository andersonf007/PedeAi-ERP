import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

/// Helper para evitar `withOpacity` deprecado (Material 3).
extension _Cx on Color {
  Color opa(double a) => withValues(alpha: a);
}

class DetalhamentoDoCaixaPage extends StatefulWidget {
  final int idCaixa;
  const DetalhamentoDoCaixaPage({Key? key, required this.idCaixa})
      : super(key: key);

  @override
  State<DetalhamentoDoCaixaPage> createState() =>
      _DetalhamentoDoCaixaPageState();
}

class _DetalhamentoDoCaixaPageState extends State<DetalhamentoDoCaixaPage> {
  Map<String, dynamic>? _dadosCaixa;
  List<Map<String, dynamic>> _formasPagamento = [];
  double _receitaPdv = 0.0;
  int _qtdVendasPdv = 0;
  bool _carregando = true;
  String? _erro;

  final _fmtMoney = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _fmtDate = DateFormat('dd/MM/yyyy');
  final _fmtDateTime = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final caixaController = CaixaCotroller();

      // Dados principais
      final caixa = await caixaController.buscarDadosDoCaixa(widget.idCaixa);

      // Formas de pagamento recebidas no caixa
      final formasPagamento =
          await caixaController.buscarPagamentosRealizadosNoCaixa(
              widget.idCaixa);

      // Receita PDV + qtd vendas PDV
      final receitaPdvResult =
          await caixaController.buscarReceitaDoPdvDoCaixa(widget.idCaixa);
      double receitaPdv = 0.0;
      int qtdVendasPdv = 0;
      if (receitaPdvResult is Map && receitaPdvResult.isNotEmpty) {
        receitaPdv =
            (receitaPdvResult['valor'] as num?)?.toDouble() ?? 0.0;
        qtdVendasPdv =
            (receitaPdvResult['total_de_vendas'] as num?)?.toInt() ?? 0;
      }

      // Saldo atual baseado nas formas recebidas
      double saldoAtual = 0.0;
      for (final forma in formasPagamento) {
        saldoAtual += (forma['valor'] as num?)?.toDouble() ?? 0.0;
      }

      setState(() {
        _dadosCaixa = {
          'id': caixa!.id,
          'data_abertura': caixa.dataAbertura,
          'periodo_abertura': caixa.periodoAbertura,
          'usuario_abertura': caixa.usuarioAbertura,
          'data_fechamento': caixa.dataFechamento,
          'periodo_fechamento': caixa.periodoFechamento,
          'usuario_fechamento': caixa.usuarioFechamento,
          'status': caixa.aberto == true ? 'ABERTO' : 'FECHADO',
          'valor_inicial': caixa.valorAbertura ?? 0.0,
          'saldo_final': saldoAtual,
        };
        _formasPagamento = formasPagamento;
        _receitaPdv = receitaPdv;
        _qtdVendasPdv = qtdVendasPdv;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao buscar detalhes do caixa: $e';
        _carregando = false;
      });
    }
  }

  // ----------------- formatadores -----------------
  String _brMoney(num v) => _fmtMoney.format(v);

  String _toDate(dynamic raw) {
    if (raw == null) return '—';
    if (raw is DateTime) return _fmtDate.format(raw);
    final d = DateTime.tryParse(raw.toString());
    return d == null ? raw.toString() : _fmtDate.format(d);
  }

  String _toDateTime(dynamic raw) {
    if (raw == null) return '—';
    if (raw is DateTime) return _fmtDateTime.format(raw);
    final d = DateTime.tryParse(raw.toString());
    return d == null ? raw.toString() : _fmtDateTime.format(d);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'Detalhamento do Caixa',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar:
          AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _erro!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                )
              : _dadosCaixa == null
                  ? Center(
                      child: Text(
                        'Nenhum dado encontrado.',
                        style: TextStyle(color: cs.onSurface.opa(.7)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarDetalhes,
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          // ---------- Cabeçalho ----------
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.onSurface.opa(.10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título + status chip
                                Row(
                                  children: [
                                    Text(
                                      'Caixa #${_dadosCaixa!['id']}',
                                      style: tt.titleMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _StatusChip(
                                      text: _dadosCaixa!['status'] == 'ABERTO'
                                          ? 'Aberto'
                                          : 'Fechado',
                                      color: _dadosCaixa!['status'] == 'ABERTO'
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(
                                  icon: Icons.login,
                                  label: 'Abertura',
                                  value:
                                      '${_toDateTime(_dadosCaixa!['data_abertura'])}  •  ${_dadosCaixa!['periodo_abertura'] ?? ''}',
                                ),
                                const SizedBox(height: 6),
                                _InfoRow(
                                  icon: Icons.logout,
                                  label: 'Fechamento',
                                  value:
                                      '${_toDateTime(_dadosCaixa!['data_fechamento'])}  •  ${_dadosCaixa!['periodo_fechamento'] ?? ''}',
                                ),
                                const SizedBox(height: 6),
                                _InfoRow(
                                  icon: Icons.person_outline,
                                  label: 'Aberto por',
                                  value:
                                      '${_dadosCaixa!['usuario_abertura'] ?? '—'}',
                                ),
                                const SizedBox(height: 6),
                                _InfoRow(
                                  icon: Icons.person,
                                  label: 'Fechado por',
                                  value:
                                      '${_dadosCaixa!['usuario_fechamento'] ?? '—'}',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ---------- KPIs ----------
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryTile(
                                  label: 'Valor inicial',
                                  value: _brMoney(
                                    (_dadosCaixa!['valor_inicial'] as num?) ??
                                        0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryTile(
                                  label: 'Receita PDV',
                                  value: _brMoney(_receitaPdv),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryTile(
                                  label: 'Vendas PDV',
                                  value: '$_qtdVendasPdv',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryTile(
                                  label: 'Saldo final',
                                  value: _brMoney(
                                    (_dadosCaixa!['saldo_final'] as num?) ??
                                        0,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ---------- Formas de pagamento ----------
                          Text(
                            'Formas de pagamento recebidas',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.onSurface.opa(.10),
                              ),
                            ),
                            child: _formasPagamento.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Nenhum pagamento encontrado.',
                                      style: TextStyle(
                                          color: cs.onSurface.opa(.7)),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      for (int i = 0;
                                          i < _formasPagamento.length;
                                          i++)
                                        Column(
                                          children: [
                                            ListTile(
                                              dense: true,
                                              title: Text(
                                                _formasPagamento[i]['nome'] ??
                                                    'Forma',
                                                style: TextStyle(
                                                  color: cs.onSurface,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              trailing: Text(
                                                _brMoney(
                                                  (_formasPagamento[i]
                                                      ['valor'] as num?) ??
                                                      0,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (i <
                                                _formasPagamento.length - 1)
                                              Divider(
                                                height: 1,
                                                color: cs.onSurface.opa(.08),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

// --------- widgets auxiliares ---------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurface.opa(.7)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.opa(.9),
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.opa(.9),
            ),
          ),
        ),
      ],
    );
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
    final bg = Color.alphaBlend(cs.primary.opa(.08), cs.surface);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.opa(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurface.opa(.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
