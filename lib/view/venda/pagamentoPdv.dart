import 'package:flutter/material.dart';
import 'package:pedeai/controller/formaPagamentoController.dart';
import 'package:pedeai/controller/vendaController.dart';
import 'package:pedeai/model/forma_pagamento.dart';
import 'package:pedeai/model/itemCarrinho.dart';
import 'package:pedeai/view/venda/pagamentoDialog.dart';
import 'package:pedeai/utils/app_notify.dart';

class PagamentoPdvPage extends StatefulWidget {
  final double subtotal;
  final double desconto;
  final double total;
  final List<ItemCarrinho> carrinho;

  const PagamentoPdvPage({
    super.key,
    required this.subtotal,
    required this.desconto,
    required this.total,
    required this.carrinho,
  });

  @override
  State<PagamentoPdvPage> createState() => _PagamentoPdvPageState();
}

class _PagamentoPdvPageState extends State<PagamentoPdvPage> {
  final FormaPagamentocontroller _formaPagamentoController =
      FormaPagamentocontroller();
  final VendaController _vendaController = VendaController();

  List<FormaPagamento> _formasPagamento = [];
  final List<Map<String, dynamic>> _pagamentosInseridos = [];

  bool _isLoading = true;
  bool _finalizando = false;

  @override
  void initState() {
    super.initState();
    _carregarFormasPagamento();
  }

  Future<void> _carregarFormasPagamento() async {
    setState(() => _isLoading = true);
    try {
      final formas = await _formaPagamentoController.listaFormaPagamentosAtivas();
      setState(() {
        _formasPagamento = formas;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppNotify.error(context, 'Erro ao carregar formas de pagamento: $e');
    }
  }

  Future<void> _showPagamentoDialog(FormaPagamento forma) async {
    final valorRestante = _faltaPagar;
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          PagamentoDialog(forma: forma, valorRestante: valorRestante),
    );

    if (resultado != null && resultado['valor'] != null) {
      setState(() {
        _pagamentosInseridos.add({
          'forma': forma,
          'valor': resultado['valor'] as double,
          'troco': (resultado['troco'] as double?) ?? 0.0,
        });
      });
    }
  }

  double get _totalPago =>
      _pagamentosInseridos.fold(0.0, (a, b) => a + (b['valor'] as double));
  double get _faltaPagar =>
      (widget.total - _totalPago) < 0 ? 0.0 : (widget.total - _totalPago);
  double get _trocoTotal =>
      _pagamentosInseridos.fold(0.0, (a, b) => a + (b['troco'] as double? ?? 0));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Pagamentos',
            style:
                TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // CPF/CNPJ
              TextField(
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Informar CNPJ/CPF do cliente',
                  hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  prefixIcon:
                      Icon(Icons.search, color: cs.onSurface.withOpacity(0.6)),
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card resumo
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _rowKV(cs, 'Subtotal',
                          'R\$ ${widget.subtotal.toStringAsFixed(2)}'),
                      _rowKV(cs, 'Desconto na venda',
                          '- R\$ ${widget.desconto.toStringAsFixed(2)}',
                          subtle: true),
                      _rowKV(cs, 'Total',
                          'R\$ ${widget.total.toStringAsFixed(2)}',
                          bold: true),
                      Divider(color: cs.outlineVariant, height: 24),

                      // Pagamentos inseridos
                      _pagamentosInseridos.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma forma de pagamento inserida',
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Column(
                              children: _pagamentosInseridos
                                  .asMap()
                                  .entries
                                  .map((e) {
                                final idx = e.key;
                                final pag = e.value;
                                final FormaPagamento forma = pag['forma'];
                                final valor = pag['valor'] as double;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(forma.nome ?? '',
                                            style: TextStyle(
                                                color: cs.onSurface)),
                                      ),
                                      Text('R\$ ${valor.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: cs.onSurface)),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: cs.error, size: 20),
                                        onPressed: () => setState(
                                            () => _pagamentosInseridos
                                                .removeAt(idx)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                      Divider(color: cs.outlineVariant, height: 24),
                      _rowKV(cs, 'Total pago',
                          'R\$ ${_totalPago.toStringAsFixed(2)}',
                          bold: true),
                      _rowKV(cs, 'Falta pagar',
                          'R\$ ${_faltaPagar.toStringAsFixed(2)}',
                          bold: true,
                          colorOverride:
                              _faltaPagar == 0 ? cs.onSurface : cs.error),
                      _rowKV(cs, 'Troco', 'R\$ ${_trocoTotal.toStringAsFixed(2)}',
                          bold: true, colorOverride: Colors.green),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Formas de pagamento
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(cs.primary)),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _formasPagamento.map((forma) {
                        IconData icon;
                        switch ((forma.tipoFormaPagamentoId ?? 1)) {
                          case 1:
                            icon = Icons.attach_money; // Dinheiro
                            break;
                          case 3:
                          case 4:
                            icon = Icons.credit_card; // Crédito/Débito
                            break;
                          case 11:
                            icon = Icons.qr_code; // PIX
                            break;
                          default:
                            icon = Icons.payment;
                        }
                        return OutlinedButton.icon(
                          icon: Icon(icon, color: cs.primary),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.primary),
                            foregroundColor: cs.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                          label: Text(
                            forma.nome ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.primary, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showPagamentoDialog(forma),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 24),

              // Finalizar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_faltaPagar != 0 || _finalizando)
                      ? null
                      : () async {
                          setState(() => _finalizando = true);
                          try {
                            final dadosVenda = {
                              'valor_total': widget.total,
                              'numero_pessoas': 1,
                              'situacao_venda': 1,
                              'tipo_venda': 'P',
                            };

                            final dadosVendaItens = <Map<String, dynamic>>[];
                            for (var i = 0; i < widget.carrinho.length; i++) {
                              final it = widget.carrinho[i];
                              dadosVendaItens.add({
                                'id_produto': it.produto.produtoIdPublic,
                                'id_produto_empresa': it.produto.id,
                                'quantidade': it.quantidade,
                                'preco_unitario': it.produto.preco,
                                'preco_total':
                                    (it.produto.preco ?? 0) * it.quantidade,
                                'situacao': 10,
                                'posicao_item': i + 1,
                                'preco_custo': it.produto.precoCusto,
                              });
                            }

                            final dadosFormaPagamento = _pagamentosInseridos
                                .map((e) => {
                                      'tipo_movimento': 'Entrada',
                                      'valor': e['valor'],
                                      'id_forma_pagamento': (e['forma'] as FormaPagamento).id,
                                      'troco': e['troco'],
                                    })
                                .toList();

                            final dadosMovEstoque =
                                widget.carrinho.map((it) => {
                                      'id_produto_empresa': it.produto.id,
                                      'quantidade': it.quantidade,
                                      'tipo_movimento': 'Saida',
                                      'motivo': 'Venda'
                                    }).toList();

                            await _vendaController.inserirVendaPdv(
                              dadosVenda: dadosVenda,
                              dadosVendaItens: dadosVendaItens,
                              dadosFormaPagamento: dadosFormaPagamento,
                              dadosMovimentacaoEstoque: dadosMovEstoque,
                            );

                            if (!mounted) return;
                            _pagamentosInseridos.clear();
                            widget.carrinho.clear();
                            AppNotify.success(
                                context, 'Venda finalizada com sucesso!');
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/pdv', (route) => false);
                          } catch (e) {
                            if (!mounted) return;
                            AppNotify.error(
                                context, 'Erro ao finalizar venda: $e');
                          } finally {
                            if (mounted) setState(() => _finalizando = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: _finalizando
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(cs.onPrimary),
                          ),
                        )
                      : const Text('Finalizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowKV(ColorScheme cs, String k, String v,
      {bool bold = false, bool subtle = false, Color? colorOverride}) {
    final style = TextStyle(
      color: colorOverride ??
          (subtle ? cs.onSurface.withOpacity(0.7) : cs.onSurface),
      fontWeight: bold ? FontWeight.bold : FontWeight.w600,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(k, style: style), Text(v, style: style)],
    );
  }
}
