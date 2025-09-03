import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';
import 'package:pedeai/utils/app_notify.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

class FechamentoCaixaPage extends StatefulWidget {
  const FechamentoCaixaPage({super.key});

  @override
  State<FechamentoCaixaPage> createState() => _FechamentoCaixaPageState();
}

class _FechamentoCaixaPageState extends State<FechamentoCaixaPage> {
  final CaixaCotroller _caixaController = CaixaCotroller();

  dynamic _caixa; // Map ou model
  List<Map<String, dynamic>> _pagamentos = [];

  bool _loading = true;
  bool _closing = false;
  String? _error;

  // formatadores
  final _fmtDate = DateFormat('dd/MM/yyyy HH:mm');
  final _fmtCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final idCaixa = await _caixaController.buscarCaixaAberto();
      if (idCaixa == -1) {
        setState(() {
          _error = 'Nenhum caixa aberto no momento.';
          _loading = false;
        });
        return;
      }

      final dados = await _caixaController.buscarDadosDoCaixa(idCaixa);
      final pags =
          await _caixaController.buscarPagamentosRealizadosNoCaixa(idCaixa);

      setState(() {
        _caixa = dados;
        _pagamentos = List<Map<String, dynamic>>.from(pags);
        _loading = false;
      });
    } on CaixaCotrollerException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro inesperado: $e';
        _loading = false;
      });
    }
  }

  // ---------- utils de parse ----------
  DateTime? _parseAnyDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) {
      if (v >= 1000000000000) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v >= 1000000000) return DateTime.fromMillisecondsSinceEpoch(v * 1000);
      return null;
    }
    if (v is String) {
      final iso = DateTime.tryParse(v);
      if (iso != null) return iso;
      try {
        final hasSec =
            RegExp(r'^\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2}$').hasMatch(v);
        final fmt = DateFormat(hasSec ? 'dd/MM/yyyy HH:mm:ss' : 'dd/MM/yyyy HH:mm');
        return fmt.parse(v);
      } catch (_) {}
    }
    return null;
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  String _getPeriodo(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 12) return 'Manhã';
    if (h >= 12 && h < 18) return 'Tarde';
    return 'Noite';
  }

  dynamic _readDynamic(dynamic obj, List<String> names) {
    if (obj == null) return null;

    if (obj is Map) {
      for (final n in names) {
        if (obj.containsKey(n)) return obj[n];
        final key = obj.keys.firstWhere(
          (k) => k.toString().toLowerCase() == n.toLowerCase(),
          orElse: () => null,
        );
        if (key != null) return obj[key];
      }
      final low = obj.map((k, v) => MapEntry(k.toString().toLowerCase(), v));
      if (names.any((n) => n.contains('abertura') && n.contains('data'))) {
        for (final e in low.entries) {
          if (e.key.contains('abert') &&
              (e.key.contains('data') ||
                  e.key.contains('open') ||
                  e.key.contains('created'))) return e.value;
        }
      }
      if (names.any((n) => n.contains('periodo') || n.contains('turno'))) {
        for (final e in low.entries) {
          if (e.key.contains('period') ||
              e.key.contains('turno') ||
              e.key.contains('shift')) return e.value;
        }
      }
      if (names.any((n) =>
          n.contains('valor') || n.contains('inicial') || n.contains('saldo'))) {
        for (final e in low.entries) {
          if ((e.key.contains('valor') || e.key.contains('saldo')) &&
              (e.key.contains('abert') ||
                  e.key.contains('inicial') ||
                  e.key.contains('inicio'))) return e.value;
        }
      }
      return null;
    }

    try {
      for (final n in names) {
        switch (n) {
          case 'dataAbertura':
            return obj.dataAbertura;
          case 'data_abertura':
            return obj.data_abertura;
          case 'abertura':
            return obj.abertura;
          case 'created_at':
            return obj.created_at;
          case 'openedAt':
            return obj.openedAt;
          case 'periodoAbertura':
            return obj.periodoAbertura;
          case 'periodo_abertura':
            return obj.periodo_abertura;
          case 'periodo':
            return obj.periodo;
          case 'turno':
            return obj.turno;
          case 'valorAbertura':
            return obj.valorAbertura;
          case 'valor_abertura':
            return obj.valor_abertura;
          case 'abertura_valor':
            return obj.abertura_valor;
          case 'saldo_inicial':
            return obj.saldo_inicial;
          case 'valor_inicial':
            return obj.valor_inicial;
          case 'id':
            return obj.id;
          case 'id_caixa':
            return obj.id_caixa;
          default:
            break;
        }
      }
    } catch (_) {}
    return null;
  }

  DateTime? _dataAbertura(dynamic c) {
    final raw = _readDynamic(c, [
      'dataAbertura',
      'data_abertura',
      'abertura',
      'openedAt',
      'created_at',
      'aberto_em',
      'dt_abertura',
    ]);
    return _parseAnyDate(raw);
  }

  String _periodoAbertura(dynamic c) {
    final raw = _readDynamic(c, [
      'periodoAbertura',
      'periodo_abertura',
      'periodo',
      'turno',
      'turno_abertura',
      'shift',
    ]);
    final s = raw?.toString().trim() ?? '';
    return s.isEmpty ? '—' : s;
  }

  double _valorAbertura(dynamic c) {
    final raw = _readDynamic(c, [
      'valorAbertura',
      'valor_abertura',
      'abertura_valor',
      'valor_inicial',
      'saldo_inicial',
    ]);
    return _asDouble(raw);
  }

  int _idCaixa(dynamic c) {
    final raw = _readDynamic(c, ['id', 'id_caixa']);
    if (raw is int) return raw;
    return int.tryParse('${raw ?? ''}') ?? -1;
  }

  double get _totalRecebido =>
      _pagamentos.fold<double>(0.0, (s, p) => s + _asDouble(p['valor']));

  Future<void> _confirmarFechamento() async {
    final cs = Theme.of(context).colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar fechamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total recebido: ${_fmtCurrency.format(_totalRecebido)}'),
            const SizedBox(height: 4),
            Text('Período de fechamento: ${_getPeriodo(DateTime.now())}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Fechar caixa'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _closing = true);
    try {
      final id = _idCaixa(_caixa);
      if (id == -1) throw Exception('ID do caixa inválido.');

      final pagamentosMap = _pagamentos
          .map((p) => {
                'id_caixa': id,
                'id_forma_de_pagamento': p['id'],
                'valor': _asDouble(p['valor']),
                'tipo_forma_pagamento_id': p['tipo_forma_pagamento_id'],
              })
          .toList();

      final dadosCaixa = {
        'id': id,
        'aberto': false,
        'data_fechamento': DateTime.now().toIso8601String(),
        'periodo_fechamento': _getPeriodo(DateTime.now()),
        'id_usuario_fechamento': '', // controller preenche
      };

      await _caixaController.fecharCaixa(pagamentosMap, dadosCaixa);

      if (!mounted) return;
      AppNotify.success(context, 'Caixa fechado com sucesso!');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      AppNotify.error(context, 'Erro ao fechar caixa: $e');
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final abertura = _dataAbertura(_caixa);
    final periodo = _periodoAbertura(_caixa);
    final valor = _valorAbertura(_caixa);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Fechamento de Caixa',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: _load,
          ),
        ],
      ),
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
      bottomNavigationBar:
          AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.error.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.error.withValues(alpha: .30),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: cs.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/aberturaCaixa'),
                          label: const Text('Abrir caixa'),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      // Card dados do caixa
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            cs.primary.withValues(alpha: .05),
                            cs.surface,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.onSurface.withValues(alpha: .10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dados do caixa',
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _kv(
                              'Data de abertura',
                              abertura != null ? _fmtDate.format(abertura) : '—',
                              cs,
                              tt,
                            ),
                            const SizedBox(height: 6),
                            _kv('Período de abertura', periodo, cs, tt),
                            const SizedBox(height: 6),
                            _kv('Valor de abertura',
                                _fmtCurrency.format(valor), cs, tt),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lista de pagamentos
                      Text(
                        'Pagamentos',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.onSurface.withValues(alpha: .10),
                          ),
                        ),
                        child: _pagamentos.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Nenhum pagamento encontrado.',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurface.withValues(alpha: .70),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _pagamentos.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: cs.outlineVariant,
                                ),
                                itemBuilder: (_, i) {
                                  final row = _pagamentos[i];
                                  final nome = (row['nome'] ??
                                          row['forma'] ??
                                          'Forma')
                                      .toString();
                                  final valor = _asDouble(row['valor']);
                                  final tipo = row['tipo_forma_pagamento_id'];
                                  final icon = _iconForTipo(tipo);

                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          cs.primary.withValues(alpha: .12),
                                      child: Icon(icon, color: cs.primary),
                                    ),
                                    title: Text(
                                      nome,
                                      style: tt.bodyMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: Text(
                                      _fmtCurrency.format(valor),
                                      style: tt.bodyMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Total recebido
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total recebido',
                            style: tt.titleMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: .85),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _fmtCurrency.format(_totalRecebido),
                            style: tt.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // CTA fechar
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _closing ? null : _confirmarFechamento,
                          child: _closing
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(cs.onPrimary),
                                  ),
                                )
                              : const Text('Fechar caixa'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Linha chave/valor estilizada
  Widget _kv(String k, String v, ColorScheme cs, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k,
            style: tt.bodyMedium
                ?.copyWith(color: cs.onSurface.withValues(alpha: .75))),
        Text(v,
            style: tt.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
      ],
    );
  }

  IconData _iconForTipo(dynamic tipo) {
    final t = (tipo is int) ? tipo : int.tryParse(tipo?.toString() ?? '') ?? -1;
    switch (t) {
      case 1:
        return Icons.attach_money; // dinheiro
      case 3:
      case 4:
        return Icons.credit_card; // crédito/débito
      case 11:
        return Icons.qr_code; // pix
      default:
        return Icons.payment;
    }
  }
}
