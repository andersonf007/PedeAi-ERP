import 'package:flutter/material.dart';
import 'package:pedeai/controller/categoriaController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/model/itemCarrinho.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/view/venda/alterarQuantidadeDialog.dart';

class PDVPage extends StatefulWidget {
  @override
  _PDVPageState createState() => _PDVPageState();
}

class _PDVPageState extends State<PDVPage> with SingleTickerProviderStateMixin {
  final Categoriacontroller _categoriaController = Categoriacontroller();
  final Produtocontroller _produtoController = Produtocontroller();

  List<Categoria> _categorias = [];
  List<Produto> _produtos = [];
  List<Produto> _produtosFiltrados = [];

  // Nova estrutura para o carrinho - mais limpa e completa
  List<ItemCarrinho> _carrinho = [];

  int _selectedTab = 0; // 0 = Produtos, 1 = Resumo
  int? _selectedCategoriaId;
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  // Variáveis de cálculo - agora calculadas dinamicamente
  double get subtotal => _carrinho.fold(0.0, (sum, item) => sum + item.valorTotal);
  double desconto = 0.0;
  double get total => subtotal - (subtotal * (desconto / 100));
  double get totalItensCarrinho => _carrinho.fold(0, (sum, item) => sum + item.quantidade);

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _searchController.addListener(_filtrarProdutos);
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final categorias = await _categoriaController.listarCategoria();
    final produtos = await _produtoController.listagemSimplesDeProdutos();
    setState(() {
      _categorias = categorias;
      _produtos = produtos;
      _selectedCategoriaId = null; // "Todos"
      _isLoading = false;
    });
    _filtrarProdutos();
  }

  void _filtrarProdutos() {
    String busca = _searchController.text.trim().toLowerCase();
    setState(() {
      _produtosFiltrados = _produtos.where((produto) {
        final matchCategoria = _selectedCategoriaId == null || produto.id_categoria == _selectedCategoriaId;
        final matchBusca = produto.descricao?.toLowerCase().contains(busca) ?? false;
        return matchCategoria && (busca.isEmpty || matchBusca);
      }).toList();
    });
  }

  void _selecionarCategoria(int? idCategoria) {
    setState(() {
      _selectedCategoriaId = idCategoria;
    });
    _filtrarProdutos();
  }

  void _adicionarAoCarrinho(Produto produto) {
    setState(() {
      // Procura se o produto já existe no carrinho
      final index = _carrinho.indexWhere((item) => item.produto.produtoIdPublic == produto.produtoIdPublic);

      if (index >= 0) {
        _carrinho[index].quantidade++;
      } else {
        // Se não existe, adiciona novo item
        _carrinho.add(ItemCarrinho(produto: produto));
      }
    });
  }

  void _removerDoCarrinho(int produtoId) {
    setState(() {
      _carrinho.removeWhere((item) => item.produto.produtoIdPublic == produtoId);
    });
  }

  void _alterarQuantidade(int produtoId, double novaQuantidade) {
    setState(() {
      final index = _carrinho.indexWhere((item) => item.produto.produtoIdPublic == produtoId);
      if (novaQuantidade <= 0) {
        if (index >= 0) {
          _removerDoCarrinho(produtoId);
        }
      } else {
        if (index >= 0) {
          _carrinho[index].quantidade = novaQuantidade;
        } else {
          // Adiciona o produto ao carrinho com a quantidade informada
          try {
            final produto = _produtos.firstWhere((p) => p.produtoIdPublic == produtoId);
            _carrinho.add(ItemCarrinho(produto: produto, quantidade: novaQuantidade));
          } catch (e) {
            // Produto não encontrado, não faz nada
          }
        }
      }
    });
  }

  double _getQuantidadeCarrinho(int produtoId) {
    try {
      final item = _carrinho.firstWhere((item) => item.produto.produtoIdPublic == produtoId);
      return item.quantidade;
    } catch (e) {
      // Se não encontrar o produto no carrinho, retorna 0
      return 0;
    }
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
          'Pedidos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
          : Column(
              children: [
                // Tabs
                Container(
                  color: Color(0xFF2D2419),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton('Produtos', 0),
                      _buildTabButton('Resumo', 1, showBadge: _carrinho.isNotEmpty, badgeCount: totalItensCarrinho),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.white24),
                Expanded(child: _selectedTab == 0 ? _buildProdutosTab() : _buildResumoTab()),
                if (_selectedTab == 1) _buildPagamentoButton(), // Só mostra na aba Resumo
              ],
            ),
    );
  }

  Widget _buildTabButton(String label, int index, {bool showBadge = false, double badgeCount = 0}) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: selected ? Colors.orange : Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (showBadge) SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), // ajuste para formato retangular
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8), // bordas arredondadas
              ),
              child: Text(
                badgeCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProdutosTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Campo de busca
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFF4A3429),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar produto',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                Icon(Icons.search, color: Colors.orange),
                SizedBox(width: 8),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Categorias
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _selecionarCategoria(null),
                  child: Container(
                    margin: EdgeInsets.only(right: 24),
                    child: Column(
                      children: [
                        Text(
                          'Todos',
                          style: TextStyle(color: _selectedCategoriaId == null ? Colors.orange : Colors.white70, fontWeight: FontWeight.bold),
                        ),
                        if (_selectedCategoriaId == null) Container(margin: EdgeInsets.only(top: 2), height: 3, width: 32, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
                ..._categorias.map(
                  (cat) => GestureDetector(
                    onTap: () => _selecionarCategoria(cat.id),
                    child: Container(
                      margin: EdgeInsets.only(right: 24),
                      child: Column(
                        children: [
                          Text(
                            cat.nome ?? '',
                            style: TextStyle(color: _selectedCategoriaId == cat.id ? Colors.orange : Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          if (_selectedCategoriaId == cat.id) Container(margin: EdgeInsets.only(top: 2), height: 3, width: 32, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Grid de produtos
          Expanded(
            child: GridView.builder(
              itemCount: _produtosFiltrados.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.60, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemBuilder: (context, index) {
                final produto = _produtosFiltrados[index];
                final quantidade = _getQuantidadeCarrinho(produto.produtoIdPublic!);
                return Builder(
                  builder: (itemContext) => GestureDetector(
                    onTap: () => _adicionarAoCarrinho(produto),
                    onLongPress: () async {
                      final box = itemContext.findRenderObject() as RenderBox;
                      final offset = box.localToGlobal(Offset.zero);

                      // Tamanho estimado do menu
                      final menuWidth = 180.0;
                      final menuHeight = 140.0;
                      final screenSize = MediaQuery.of(context).size;

                      // Posiciona para que a ponta superior esquerda do menu fique no centro do item
                      double left = offset.dx + (box.size.width / 2);
                      double top = offset.dy + (box.size.height / 2);

                      // Garante que o menu não ultrapasse os limites da tela
                      if (left < 8) left = 8;
                      if (left + menuWidth > screenSize.width) left = screenSize.width - menuWidth - 8;
                      if (top + menuHeight > screenSize.height) top = screenSize.height - menuHeight - 8;

                      final selected = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(left, top, left + menuWidth, top + menuHeight),
                        items: [PopupMenuItem(value: 'quantidade', child: Text('Quantidade'))],
                      );

                      if (selected == 'quantidade') {
                        final quantidadeAtual = _getQuantidadeCarrinho(produto.produtoIdPublic!);
                        final novaQuantidade = await showDialog<double>(
                          context: context,
                          builder: (context) => QuantidadeDialog(quantidadeAtual: quantidadeAtual, nomeProduto: produto.descricao ?? '', precoUnitario: produto.preco ?? 0.0),
                        );
                        if (novaQuantidade != null) {
                          _alterarQuantidade(produto.produtoIdPublic!, novaQuantidade);
                        }
                      }
                      // Implemente as outras opções se desejar
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF4A3429),
                            border: Border.all(color: Colors.orange, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: produto.image_url != '' && produto.image_url.isNotEmpty
                                      ? Image.network(
                                          produto.image_url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, color: Colors.orange, size: 32),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.fastfood, color: Colors.orange, size: 32),
                                        ),
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                height: 48,
                                child: Center(
                                  child: Text(
                                    produto.descricao?.toUpperCase() ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                height: 18,
                                child: Center(
                                  child: Text(
                                    'R\$ ${produto.preco?.toStringAsFixed(2) ?? '0.00'} UN',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (quantidade > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), // ajuste para formato retangular
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8), // bordas arredondadas
                              ),
                              child: Text(
                                quantidade.toString(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildResumoTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Color(0xFF4A3429),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _carrinho.isEmpty
                    ? Center(
                        child: Text('Nenhum produto selecionado', style: TextStyle(color: Colors.white70)),
                      )
                    : ListView.builder(
                        itemCount: _carrinho.length,
                        itemBuilder: (context, index) {
                          final itemCarrinho = _carrinho[index];
                          final produto = itemCarrinho.produto;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produto.descricao ?? '',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text('${itemCarrinho.quantidade} UN x R\$ ${produto.preco?.toStringAsFixed(2) ?? '0,00'}', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                // Controles de quantidade
                                /*Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.orange, size: 20),
                                      onPressed: () => _alterarQuantidade(produto.produtoIdPublic!, itemCarrinho.quantidade - 1),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        itemCarrinho.quantidade.toString(),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: Colors.orange, size: 20),
                                      onPressed: () => _alterarQuantidade(produto.produtoIdPublic!, itemCarrinho.quantidade + 1),
                                    ),
                                  ],
                                ),*/
                                Text(
                                  'R\$ ${itemCarrinho.valorTotal.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _removerDoCarrinho(produto.produtoIdPublic!),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'R\$ ${subtotal.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Desconto na venda', style: TextStyle(color: Colors.white70)),
            Text('- R\$ ${(subtotal * (desconto / 100)).toStringAsFixed(2)}', style: TextStyle(color: Colors.white70)),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
            Text(
              'R\$ ${total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPagamentoButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: _carrinho.isEmpty
            ? null
            : () {
                // Agora você tem acesso completo aos produtos no carrinho
                final dadosPagamento = {'subtotal': subtotal, 'desconto': desconto, 'total': total, 'carrinho': _carrinho};
                Navigator.of(context).pushNamed('/pagamentoPdv', arguments: dadosPagamento);
              },
        child: Text(
          'Pagamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
