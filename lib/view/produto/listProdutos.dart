import 'package:flutter/material.dart';
import 'package:pedeai/view/home/home.dart';
import 'package:pedeai/view/produto/cadastroProduto.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/model/produto.dart';

class ProductsListPage extends StatefulWidget {
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  int _selectedIndex = 2;
  String _selectedFilter = 'Ativos';
  TextEditingController _searchController = TextEditingController();
  
  final Produtocontroller _produtoController = Produtocontroller();
  List<Produto> _produtos = [];
  List<Produto> _produtosFiltrados = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filtrarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Produto> produtos = await _produtoController.listarProdutos();
      setState(() {
        _produtos = produtos;
        _isLoading = false;
      });
      _filtrarProdutos();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar produtos: $e';
        _isLoading = false;
      });
    }
  }

  void _filtrarProdutos() {
    List<Produto> produtosFiltrados = List.from(_produtos);

    // Filtrar por status (Ativos/Inativos/Todos)
    switch (_selectedFilter) {
      case 'Ativos':
        produtosFiltrados = produtosFiltrados.where((produto) => produto.estoque > 0).toList();
        break;
      case 'Inativos':
        produtosFiltrados = produtosFiltrados.where((produto) => produto.estoque == 0).toList();
        break;
      case 'Todos':
      default:
        break;
    }

    // Filtrar por termo de busca
    String termoBusca = _searchController.text.toLowerCase();
    if (termoBusca.isNotEmpty) {
      produtosFiltrados = produtosFiltrados.where((produto) {
        return produto.descricao.toLowerCase().contains(termoBusca) ||
               produto.codigo.toLowerCase().contains(termoBusca);
      }).toList();
    }

    setState(() {
      _produtosFiltrados = produtosFiltrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        centerTitle: true,
        title: Text(
          'Lista de Produtos',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarProdutos,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterButton('Ativos', _selectedFilter == 'Ativos'),
                SizedBox(width: 8),
                _buildFilterButton('Inativos', _selectedFilter == 'Inativos'),
                SizedBox(width: 8),
                _buildFilterButton('Todos', _selectedFilter == 'Todos'),
              ]
            ),
          ),

          // Barra de pesquisa
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar produtos',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF4A3429),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),

          SizedBox(height: 16),

          // Conteúdo principal
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CadastroProdutoPage())
          );
          
          // Recarregar lista se um produto foi adicionado
          if (result == true) {
            _carregarProdutos();
          }
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.orange, size: 64),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarProdutos,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_produtosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty 
                  ? 'Nenhum produto encontrado para "${_searchController.text}"'
                  : 'Nenhum produto encontrado',
              style: TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarProdutos,
      color: Colors.orange,
      backgroundColor: Color(0xFF4A3429),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _produtosFiltrados.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_produtosFiltrados[index]);
        },
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
        _filtrarProdutos();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Color(0xFF4A3429),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ),
    );
  }

// Modifique o método _buildProductCard na classe ProductsListPage:

  Widget _buildProductCard(Produto produto) {
    return GestureDetector(
      onTap: () async {
        // Navegar para tela de edição
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CadastroProdutoPage(
              produtoId: produto.produtoIdPublic, // Passa o ID do produto para edição
            )
          )
        );
        
        // Recarregar lista se houve alteração
        if (result == true) {
          _carregarProdutos();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF4A3429),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(
          children: [
            // Ícone do produto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF2D2419),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(
                produto.estoque > 0 ? Icons.inventory : Icons.inventory_2_outlined,
                color: produto.estoque > 0 ? Colors.orange : Colors.white54,
                size: 30
              ),
            ),
            SizedBox(width: 16),

            // Informações do produto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código: ${produto.codigo}',
                    style: TextStyle(color: Colors.white54, fontSize: 10)
                  ),
                  SizedBox(height: 2),
                  Text(
                    produto.descricao,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${produto.precoFormatado} | ${produto.unidadesFormatado}',
                    style: TextStyle(color: Colors.white70, fontSize: 12)
                  ),
                ],
              ),
            ),

            // Indicador de status e ícone de edição
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: produto.estoque > 0 ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    produto.estoque > 0 ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.edit,
                  color: Colors.orange,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Painel'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Vendas'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produtos'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estoque'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}