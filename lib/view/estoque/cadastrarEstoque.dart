import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedeai/controller/estoqueController.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/app_nav_bar.dart';

class EstoqueDetalhePage extends StatefulWidget {
  const EstoqueDetalhePage({super.key, required this.produto});
  final Produto produto;

  @override
  State<EstoqueDetalhePage> createState() => _EstoqueDetalhePageState();
}

class _EstoqueDetalhePageState extends State<EstoqueDetalhePage> {
  final _estoque = Estoquecontroller();

  bool _loading = true;
  String? _error;
  List<_Mov> _movs = [];
  String _filtro = 'Todos'; // Todos | Entrada | Saída

  // 👇 controla o estoque atual exibido (não altera o Produto final)
  late double _estoqueAtual;

  @override
  void initState() {
    super.initState();
    _estoqueAtual = (widget.produto.estoque ?? 0).toDouble();
    _loadMovs();
  }

  Future<void> _loadMovs() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final raw = await _estoque.listarMovimentosDoProduto(widget.produto.id);
      final list = raw.map<_Mov>((m) => _Mov.fromMap(m)).toList();

      // ordena por data ASC p/ calcular saldo corrido
      list.sort((a, b) => a.data.compareTo(b.data));

      // saldo corrido: começando de 0 (histórico) — saldo após cada movimento
      double saldo = 0;
      for (final m in list) {
        saldo += m.sign * m.quantidade;
        m.saldoApos = saldo;
      }

      // exibe (UI) do mais novo pro mais antigo
      list.sort((a, b) => b.data.compareTo(a.data));

      setState(() {
        _movs = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar movimentos: $e';
        _loading = false;
      });
    }
  }

  List<_Mov> get _filtrados {
    if (_filtro == 'Todos') return _movs;
    if (_filtro == 'Entrada') {
      return _movs.where((m) => m.tipo == 'Entrada').toList();
    }
    return _movs.where((m) => m.tipo == 'Saida' || m.tipo == 'Saída').toList();
  }

  Future<void> _novaMovimentacao() async {
    final cs = Theme.of(context).colorScheme;
    final qtd = TextEditingController();
    String tipo = 'Entrada';
    String motivo = 'Compra';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setM) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nova movimentação',
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  // Entrada/Saída
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Entrada'),
                        selected: tipo == 'Entrada',
                        onSelected: (_) => setM(() => tipo = 'Entrada'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Saída'),
                        selected: tipo == 'Saída' || tipo == 'Saida',
                        onSelected: (_) => setM(() => tipo = 'Saída'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: motivo,
                    items: const [
                      DropdownMenuItem(
                          value: 'Compra', child: Text('Motivo: Compra')),
                      DropdownMenuItem(
                          value: 'Venda', child: Text('Motivo: Venda')),
                      DropdownMenuItem(
                          value: 'Ajuste de Inventário',
                          child: Text('Motivo: Ajuste de Inventário')),
                      DropdownMenuItem(
                          value: 'Outro', child: Text('Motivo: Outro')),
                    ],
                    onChanged: (v) => setM(() => motivo = v ?? 'Compra'),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.info_outline)),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: qtd,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      hintText: 'Ex: 10 ou 10,5',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*[,.]?\d{0,4}$'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final q = double.tryParse(
                                  qtd.text.replaceAll(',', '.'),
                                ) ??
                                0;
                            if (q <= 0) return;

                            // 1) grava o movimento
                            await _estoque.inserirMovimentacaoEstoque({
                              'id_produto_empresa': widget.produto.id,
                              'quantidade': q,
                              'tipo_movimento':
                                  (tipo == 'Saída') ? 'Saida' : 'Entrada',
                              'motivo': motivo,
                            });

                            // 2) atualiza a quantidade (permitindo negativo)
                            final novo = (tipo == 'Saída')
                                ? (_estoqueAtual - q)
                                : (_estoqueAtual + q);

                            await _estoque.atualizarQuantidadeEstoque({
                              'id_produto_empresa': widget.produto.id,
                              'quantidade': novo,
                            });

                            // 3) atualiza SOMENTE o estado local
                            if (mounted) {
                              setState(() => _estoqueAtual = novo);
                              Navigator.pop(ctx);
                              _loadMovs();
                            }
                          },
                          child: const Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = widget.produto;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text(p.descricao ?? 'Produto')),
      bottomNavigationBar:
          AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),
      floatingActionButton: FloatingActionButton(
        onPressed: _novaMovimentacao,
        child: const Icon(Icons.add),
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
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    // Imagem grande
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: (p.image_url ?? '').isEmpty
                            ? Container(
                                color: cs.onSurface.withValues(alpha: .06),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image,
                                  color:
                                      cs.onSurface.withValues(alpha: .35),
                                  size: 48,
                                ),
                              )
                            : Image.network(
                                p.image_url!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: cs.onSurface.withValues(alpha: .06),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: cs.onSurface
                                        .withValues(alpha: .35),
                                    size: 48,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Movimentos de Estoque',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        PopupMenuButton<String>(
                          initialValue: _filtro,
                          onSelected: (v) => setState(() => _filtro = v),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'Todos', child: Text('Todos')),
                            PopupMenuItem(
                                value: 'Entrada', child: Text('Entrada')),
                            PopupMenuItem(
                                value: 'Saída', child: Text('Saída')),
                          ],
                          child: OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.filter_list),
                            label: Text(_filtro),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Estoque atual: ${_estoqueAtual.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: .75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ..._filtrados.map((m) => _MovTile(mov: m)),
                    if (_filtrados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                          child: Text(
                            'Sem movimentos para o filtro selecionado.',
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: .7),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _Mov {
  _Mov({
    required this.data,
    required this.tipo,
    required this.quantidade,
    required this.motivo,
  });

  final DateTime data;
  final String tipo; // 'Entrada' | 'Saida'|'Saída'
  final double quantidade; // sempre positivo
  final String motivo;
  double? saldoApos; // preenchido no cálculo corrido

  double get sign => (tipo == 'Saida' || tipo == 'Saída') ? -1.0 : 1.0;

  factory _Mov.fromMap(Map<String, dynamic> m) {
    final rawData = m['data'] ?? m['created_at'] ?? DateTime.now().toString();
    final dt = rawData is DateTime
        ? rawData
        : DateTime.tryParse(rawData.toString()) ?? DateTime.now();
    return _Mov(
      data: dt,
      tipo: (m['tipo_movimento'] ?? m['tipo'] ?? 'Entrada').toString(),
      quantidade: (m['quantidade'] is num)
          ? (m['quantidade'] as num).toDouble()
          : double.tryParse('${m['quantidade']}') ?? 0.0,
      motivo: (m['motivo'] ?? '—').toString(),
    );
  }
}

class _MovTile extends StatelessWidget {
  const _MovTile({required this.mov});
  final _Mov mov;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isSaida = mov.sign < 0;
    final qtdText =
        (isSaida ? '-' : '+') + mov.quantidade.toStringAsFixed(2);
    final qtdColor = isSaida ? Colors.redAccent : Colors.green;

    final dataFmt =
        '${_2(mov.data.day)}/${_2(mov.data.month)}/${mov.data.year}, ${_2(mov.data.hour)}:${_2(mov.data.minute)}';
    final saldoStr =
        mov.saldoApos == null ? '—' : mov.saldoApos!.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                dataFmt,
                style:
                    tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Motivo: ${mov.motivo}',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: .75),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${isSaida ? 'Saída' : 'Entrada'}: $qtdText',
                style: tt.bodySmall?.copyWith(color: qtdColor),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Saldo:',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: .70),
                ),
              ),
              Text(
                saldoStr,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _2(int n) => n.toString().padLeft(2, '0');
}
