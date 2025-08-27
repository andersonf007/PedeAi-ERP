import 'package:flutter/material.dart';
import 'package:pedeai/controller/formaPagamentoController.dart';
import 'package:pedeai/model/forma_pagamento.dart';
import 'package:pedeai/model/itemCarrinho.dart';
import 'package:pedeai/view/venda/pagamentoDialog.dart';

class PagamentoPdvPage extends StatefulWidget {
  final double subtotal;
  final double desconto;
  final double total;
  List<ItemCarrinho> carrinho;
  PagamentoPdvPage({Key? key, required this.subtotal, required this.desconto, required this.total, required this.carrinho}) : super(key: key);

  @override
  State<PagamentoPdvPage> createState() => _PagamentoPdvPageState();
}

class _PagamentoPdvPageState extends State<PagamentoPdvPage> {
  final FormaPagamentocontroller _formaPagamentoController = FormaPagamentocontroller();
  List<FormaPagamento> _formasPagamento = [];
  List<Map<String, dynamic>> _pagamentosInseridos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFormasPagamento();
  }

  Future<void> _carregarFormasPagamento() async {
    setState(() => _isLoading = true);
    final formas = await _formaPagamentoController.listaFormaPagamentosAtivas();
    setState(() {
      _formasPagamento = formas;
      _isLoading = false;
    });
  }

  void _adicionarPagamento(FormaPagamento forma) {
    setState(() {
      _pagamentosInseridos.add({
        'forma': forma,
        'valor': 0.0, 
      });
    });
  }

  double _calcularValorRestante() {
    return _faltaPagar;
  }

  Future<void> _showPagamentoDialog(FormaPagamento forma) async {
    final valorRestante = _calcularValorRestante();
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PagamentoDialog(forma: forma, valorRestante: valorRestante),
    );

    if (resultado != null && resultado['valor'] != null) {
      setState(() {
        _pagamentosInseridos.add({'forma': forma, 'valor': resultado['valor'], 'troco': resultado['troco'] ?? 0.0});
      });
    }
  }

  double get _totalPago => _pagamentosInseridos.fold(0.0, (a, b) => a + (b['valor'] as double));
  double get _faltaPagar => (widget.total - _totalPago) < 0 ? 0.0 : (widget.total - _totalPago);
  double get _trocoTotal => _pagamentosInseridos.fold(0.0, (a, b) => a + (b['troco'] as double? ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pagamentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Campo de CPF/CNPJ
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4A3429),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Informar Cnpj/Cpf do cliente',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.orange),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Card de resumo
              Card(
                color: Color(0xFF4A3429),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(color: Colors.white)),
                          Text('R\$ ${widget.subtotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Desconto na venda', style: TextStyle(color: Colors.white)),
                          Text('- R\$ ${widget.desconto.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${widget.total.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white24, height: 24),
                      // Lista de formas de pagamento inseridas
                      _pagamentosInseridos.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma forma de pagamento inserida',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            )
                          : Column(
                              children: _pagamentosInseridos.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final pag = entry.value;
                                final forma = pag['forma'] as FormaPagamento;
                                final valor = pag['valor'] as double;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(forma.nome ?? '', style: TextStyle(color: Colors.white)),
                                      ),
                                      Text('R\$ ${valor.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.orange, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _pagamentosInseridos.removeAt(idx);
                                            // Os getters _totalPago e _faltaPagar já recalculam automaticamente
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total pago',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'R\$ ${_totalPago.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Falta pagar',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${_faltaPagar.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Troco',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${_trocoTotal.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Botões das formas de pagamento
              _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
                  : Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: _formasPagamento.map((forma) {
                        IconData icon;
                        switch ((forma.tipoFormaPagamentoId ?? 1)) {
                          case 1:
                            icon = Icons.attach_money;
                            break;
                          case 3:
                            icon = Icons.credit_card;
                            break;
                          case 4:
                            icon = Icons.credit_card;
                            break;
                          case 11:
                            icon = Icons.qr_code;
                            break;
                          default:
                            icon = Icons.payment;
                        }
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 2,
                          ),
                          icon: Icon(icon, color: Colors.orange),
                          label: Text(
                            forma.nome ?? '',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            _showPagamentoDialog(forma);
                          },
                        );
                      }).toList(),
                    ),
              SizedBox(height: 32),
              // Botão Finalizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    if (_faltaPagar != 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('O pagamento não está completo.'), backgroundColor: Colors.red));
                      return;
                    }
Map<String, dynamic> dadosVenda = {
                    'valor_total': widget.total,
                    'numero_pessoas': 1,
                    'situacao_venda': 1,
                    'tipo_venda': 'P',
                  };

  List<Map<String, dynamic>> dadosVendaItens = [];

  for (int i = 0; i < widget.carrinho.length; i++) {
    final item = widget.carrinho[i];

    dadosVendaItens.add({
      'id_produto': widget.carrinho[i].produto.produtoIdPublic,
      'id_produto_empresa': widget.carrinho[i].produto.id,
      'quantidade': widget.carrinho[i].quantidade,
      'preco_unitario': widget.carrinho[i].produto.preco,
      'preco_total': widget.carrinho[i].produto.preco * widget.carrinho[i].quantidade,
      'situacao': 10,
      'posicao_item': i + 1,
      'preco_custo': widget.carrinho[i].produto.precoCusto,
    });
  }

  List<Map<String, dynamic>> dadosFormaPagamento = [];

  for (int i = 0; i < _pagamentosInseridos.length; i++) {
    final item = _pagamentosInseridos[i];

    dadosFormaPagamento.add({
      'tipo_movimento': 'Entrada',
      'valor': item['valor'],
      'id_forma_pagamento': item['forma'].id,
      'troco': item['troco'],
    });
  }

                  },
                  child: Text(
                    'Finalizar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
