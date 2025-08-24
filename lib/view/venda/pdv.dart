import 'package:flutter/material.dart';
import 'package:pedeai/controller/categoriaController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/model/produto.dart';

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
  Map<int, int> _carrinho = {};
  int _selectedTab = 0; // 0 = Produtos, 1 = Resumo
  int? _selectedCategoriaId;
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

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
      _carrinho[produto.produtoIdPublic!] = (_carrinho[produto.produtoIdPublic!] ?? 0) + 1;
    });
  }

  void _removerDoCarrinho(int produtoId) {
    setState(() {
      _carrinho.remove(produtoId);
    });
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
        leading: BackButton(color: Colors.white),
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
                      _buildTabButton('Resumo', 1, showBadge: _carrinho.isNotEmpty, badgeCount: _carrinho.values.fold(0, (a, b) => a + b)),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.white24),
                Expanded(child: _selectedTab == 0 ? _buildProdutosTab() : _buildResumoTab()),
                _buildPagamentoButton(),
              ],
            ),
    );
  }

  Widget _buildTabButton(String label, int index, {bool showBadge = false, int badgeCount = 0}) {
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
            if (showBadge)
              Container(
                margin: EdgeInsets.only(left: 6),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
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
                final quantidade = _carrinho[produto.produtoIdPublic] ?? 0;
                return GestureDetector(
                  onTap: () => _adicionarAoCarrinho(produto),
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
                                  produto.descricao.toUpperCase() ?? '',
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
                                  'R\$ ${produto.preco.toStringAsFixed(2) ?? '0.00'} UN',
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
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: Text(
                              quantidade.toString(),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
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
    final itensCarrinho = _produtos.where((p) => _carrinho[p.produtoIdPublic!] != null).toList();
    double subtotal = 0.0;
    for (var produto in itensCarrinho) {
      final qtd = _carrinho[produto.produtoIdPublic!] ?? 0;
      subtotal += (produto.preco ?? 0.0) * qtd;
    }
    double desconto = 0.0; // estático
    double total = subtotal - desconto;

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
                child: itensCarrinho.isEmpty
                    ? Center(
                        child: Text('Nenhum produto selecionado', style: TextStyle(color: Colors.white70)),
                      )
                    : ListView.builder(
                        itemCount: itensCarrinho.length,
                        itemBuilder: (context, index) {
                          final produto = itensCarrinho[index];
                          final qtd = _carrinho[produto.produtoIdPublic!] ?? 0;
                          final valorTotal = (produto.preco ?? 0.0) * qtd;
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
                                      Text('$qtd UN x R\$ ${produto.preco?.toStringAsFixed(2) ?? '0,00'}', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text(
                                  'R\$ ${valorTotal.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.orange, size: 20),
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
              Text('- R\$ ${desconto.toStringAsFixed(2)}', style: TextStyle(color: Colors.white70)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
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
        onPressed: () {
          // Implementar funcionalidade de pagamento futuramente
        },
        child: Text(
          'Pagamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
