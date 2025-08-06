// products_list_page.dart
import 'package:flutter/material.dart';
import 'package:pedeai/view/home/home.dart';
import 'package:pedeai/view/produto/cadastroProduto.dart';

class ProductsListPage extends StatefulWidget {
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  int _selectedIndex = 2; // Produtos está selecionado
  String _selectedFilter = 'Ativos';
  TextEditingController _searchController = TextEditingController();

  // Dados mockados dos produtos
  List<Map<String, dynamic>> products = [
    {'id': '000001', 'name': 'Hambúrguer Artesanal', 'price': 'R\$ 25,00', 'category': 'Sanduíche', 'units': '15 unidades', 'image': Icons.fastfood},
    {'id': '000002', 'name': 'Pizza Margherita', 'price': 'R\$ 35,00', 'category': 'Pizza', 'units': '8 unidades', 'image': Icons.local_pizza},
    {'id': '000003', 'name': 'Refrigerante de Cola', 'price': 'R\$ 6,00', 'category': 'Bebida', 'units': '24 unidades', 'image': Icons.local_drink},
  ];

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
        /*leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),*/
        actions: [
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
            child: Row(children: [_buildFilterButton('Ativos', _selectedFilter == 'Ativos'), SizedBox(width: 8), _buildFilterButton('Inativos', _selectedFilter == 'Inativos'), SizedBox(width: 8), _buildFilterButton('Todos', _selectedFilter == 'Todos')]),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),

          SizedBox(height: 16),

          // Lista de produtos
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroProdutoPage()));
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.orange : Color(0xFF4A3429), borderRadius: BorderRadius.circular(20)),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          // Imagem do produto
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: Color(0xFF2D2419), borderRadius: BorderRadius.circular(8)),
            child: Icon(product['image'], color: Colors.orange, size: 30),
          ),
          SizedBox(width: 16),

          // Informações do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código: ${product['id']}', style: TextStyle(color: Colors.white54, fontSize: 10)),
                SizedBox(height: 2),
                Text(
                  product['name'],
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('${product['price']} | ${product['category']} | ${product['units']}', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
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
