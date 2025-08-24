import 'package:flutter/material.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/controller/estoqueController.dart';
import 'package:pedeai/model/produto.dart';

class EstoquePage extends StatefulWidget {
  @override
  _EstoquePageState createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final Produtocontroller _produtoController = Produtocontroller();
  final Estoquecontroller _estoqueController = Estoquecontroller();
  int _selectedIndex = 3;

  Produto? _produtoSelecionado;
  double? _estoqueAtual;
  bool _isEntrada = true;
  TextEditingController _quantidadeController = TextEditingController();

  Future<void> _buscarProduto() async {
    final produtos = await _produtoController.listagemSimplesDeProdutos();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color(0xFF4A3429),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return ListTile(
                  title: Text(produto.descricao ?? '', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Estoque: ${produto.estoque}', style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    setState(() {
                      _produtoSelecionado = produto;
                      _estoqueAtual = (produto.estoque ?? 0.0) as double?;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _salvarMovimentacao() async {
    if (_produtoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione um produto!'), backgroundColor: Colors.red));
      return;
    }
    double quantidade = double.tryParse(_quantidadeController.text.replaceAll(',', '.')) ?? 0.0;
    if (quantidade == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Informe uma quantidade válida!'), backgroundColor: Colors.red));
      return;
    }

    String tipoMovimento = _isEntrada ? 'Entrada' : 'Saida';

    // Inserir movimentação
    await _estoqueController.inserirMovimentacaoEstoque({'id_produto_empresa': _produtoSelecionado!.id, 'quantidade': quantidade, 'tipo_movimento': tipoMovimento});

    // Calcular novo estoque
    double novoEstoque = _estoqueAtual ?? 0.0;
    if (_isEntrada) {
      novoEstoque += quantidade;
    } else {
      novoEstoque -= quantidade;
      if (novoEstoque < 0) novoEstoque = 0;
    }

    // Atualizar estoque
    await _estoqueController.atualizarQuantidadeEstoque({'id_produto_empresa': _produtoSelecionado!.id, 'quantidade': novoEstoque});

    setState(() {
      _estoqueAtual = novoEstoque;
      _quantidadeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Movimentação salva com sucesso!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Movimentação de Estoque',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botão de busca de produto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(Icons.search, color: Colors.white),
                label: Text(
                  'Buscar Produto',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _buscarProduto,
              ),
            ),
            SizedBox(height: 24),
            if (_produtoSelecionado != null) ...[
              Text(
                'Produto: ${_produtoSelecionado!.descricao ?? ''}',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Estoque atual: ${_estoqueAtual?.toStringAsFixed(2) ?? '0.00'}', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4A3429),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Movimento',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: _isEntrada,
                          onChanged: (value) {
                            setState(() {
                              _isEntrada = value!;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                        Text(
                          'SAÍDA',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 24),
                        Radio<bool>(
                          value: true,
                          groupValue: _isEntrada,
                          onChanged: (value) {
                            setState(() {
                              _isEntrada = value!;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                        Text(
                          'ENTRADA',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _quantidadeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF4A3429),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: 'Ex: 85.54',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                onChanged: (value) {
                  // Aceita ponto ou vírgula, converte vírgula para ponto
                  String novoValor = value.replaceAll(',', '.');
                  if (novoValor != value) {
                    _quantidadeController.value = TextEditingValue(
                      text: novoValor,
                      selection: TextSelection.collapsed(offset: novoValor.length),
                    );
                  }
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _salvarMovimentacao,
                  child: Text(
                    'Salvar Movimentação',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF2D2419),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.white70,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 0) {
          Navigator.of(context).pushNamed('/home', arguments: null);
        } /*else if (index == 1) {
          Navigator.of(context).pushNamed('/listVendas', arguments: null);
        } */ else if (index == 2) {
          Navigator.of(context).pushNamed('/listProdutos', arguments: null);
        }else if (index == 3) {
          Navigator.of(context).pushNamed('/estoque', arguments: null);
        } else if (index == 4) {
          Navigator.of(context).pushNamed('/listUsuarios', arguments: null);
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Painel'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Vendas'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produtos'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estoque'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuários'),
      ],
    );
  }
}
