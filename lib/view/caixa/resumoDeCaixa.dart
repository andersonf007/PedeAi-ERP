import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

extension _Cx on Color {
  Color opa(double a) => withValues(alpha: a);
}

class ResumoDeCaixaPage extends StatefulWidget {
  const ResumoDeCaixaPage({Key? key}) : super(key: key);

  @override
  State<ResumoDeCaixaPage> createState() => _ResumoDeCaixaPageState();
}

enum _PeriodoChip { hoje, ultimos7, ultimoMes, personalizado }

class _ResumoDeCaixaPageState extends State<ResumoDeCaixaPage> {
  final CaixaCotroller _caixaController = CaixaCotroller();

  DateTime _dataInicial = DateTime.now();
  DateTime _dataFinal = DateTime.now();
  _PeriodoChip _selecionado = _PeriodoChip.hoje;

  List<Map<String, dynamic>> _caixas = [];
  bool _carregando = false;
  String? _erro;
  int? _caixaSelecionado;

  @override
  void initState() {
    super.initState();
    _aplicarPeriodo(_PeriodoChip.hoje);
  }

  Future<void> _buscarCaixas() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final caixas =
          await _caixaController.buscarDatasDosCaixas(_dataInicial, _dataFinal);
      setState(() {
        _caixas = caixas;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao buscar caixas: $e';
        _carregando = false;
      });
    }
  }

  void _aplicarPeriodo(_PeriodoChip chip) async {
    DateTime hoje = DateTime.now();
    DateTime ini = _dataInicial;
    DateTime fim = _dataFinal;

    switch (chip) {
      case _PeriodoChip.hoje:
        ini = DateTime(hoje.year, hoje.month, hoje.day);
        fim = DateTime(hoje.year, hoje.month, hoje.day);
        break;
      case _PeriodoChip.ultimos7:
        final d0 = DateTime(hoje.year, hoje.month, hoje.day);
        ini = d0.subtract(const Duration(days: 6));
        fim = d0;
        break;
      case _PeriodoChip.ultimoMes:
        final mes = hoje.month == 1 ? 12 : hoje.month - 1;
        final ano = hoje.month == 1 ? hoje.year - 1 : hoje.year;
        ini = DateTime(ano, mes, 1);
        fim = DateTime(ano, mes + 1, 0);
        break;
      case _PeriodoChip.personalizado:
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2022, 1, 1),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(start: _dataInicial, end: _dataFinal),
          helpText: 'Selecione o período',
          saveText: 'Aplicar',
        );
        if (range == null) return;
        ini = DateTime(range.start.year, range.start.month, range.start.day);
        fim = DateTime(range.end.year, range.end.month, range.end.day);
        break;
    }

    setState(() {
      _selecionado = chip;
      _dataInicial = ini;
      _dataFinal = fim;
    });

    await _buscarCaixas();
  }

  String _formatarData(dynamic data) {
    if (data == null) return '—';
    final d = DateTime.tryParse(data.toString());
    if (d == null) return data.toString();
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
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
          'Resumo de Caixa',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar:
          AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: Column(
        children: [
          // --------- CHIPS EM UMA ÚNICA LINHA (rolagem horizontal) ---------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PeriodoChipPill(
                    texto: 'Hoje',
                    selected: _selecionado == _PeriodoChip.hoje,
                    onTap: () => _aplicarPeriodo(_PeriodoChip.hoje),
                  ),
                  const SizedBox(width: 12),
                  _PeriodoChipPill(
                    texto: 'Últimos 7 dias',
                    selected: _selecionado == _PeriodoChip.ultimos7,
                    onTap: () => _aplicarPeriodo(_PeriodoChip.ultimos7),
                  ),
                  const SizedBox(width: 12),
                  _PeriodoChipPill(
                    texto: 'Último mês',
                    selected: _selecionado == _PeriodoChip.ultimoMes,
                    onTap: () => _aplicarPeriodo(_PeriodoChip.ultimoMes),
                  ),
                  const SizedBox(width: 12),
                  _PeriodoChipPill(
                    texto: 'Personalizado',
                    selected: _selecionado == _PeriodoChip.personalizado,
                    onTap: () => _aplicarPeriodo(_PeriodoChip.personalizado),
                    icon: Icons.date_range,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _carregando
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
                    : _caixas.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum caixa encontrado.',
                              style: TextStyle(color: cs.onSurface.opa(.7)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _caixas.length,
                            itemBuilder: (context, index) {
                              final c = _caixas[index];
                              final selecionado = _caixaSelecionado == c['id'];
                              final aberto = (c['aberto'] == true) ||
                                  (c['data_fechamento'] == null);

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selecionado
                                        ? cs.primary
                                        : cs.onSurface.opa(.10),
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _caixaSelecionado = c['id'];
                                    });
                                    Navigator.of(context).pushNamed(
                                        '/detalhamentoCaixa',
                                        arguments: c['id']);
                                  },
                                  title: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: aberto
                                              ? Colors.orange
                                              : Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        'Caixa #${c['id']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${aberto ? 'Aberto' : 'Fechado'}',
                                        style: TextStyle(
                                          color: cs.onSurface.opa(.70),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Abertura: ${_formatarData(c['data_abertura'])}   •   '
                                      'Fechamento: ${_formatarData(c['data_fechamento'])}',
                                      style: TextStyle(
                                        color: cs.onSurface.opa(.75),
                                      ),
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: cs.onSurface.opa(.7),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// -------------- CHIP --------------

class _PeriodoChipPill extends StatelessWidget {
  const _PeriodoChipPill({
    required this.texto,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String texto;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? cs.primary : cs.onSurface.opa(.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? cs.onPrimary : cs.onSurface),
              const SizedBox(width: 6),
            ],
            Text(
              texto,
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
