import 'package:flutter/material.dart';
import 'package:pedeai/view/produto/listProdutos.dart';
import 'package:pedeai/view/produto/cadastroProduto.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        title: Text(
          'Painel',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fluxo de Caixa Section
            Text(
              'Fluxo de Caixa',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFinanceCard('Receitas', 'R\$ 12.500,00', Colors.green.shade700)),
                SizedBox(width: 12),
                Expanded(child: _buildFinanceCard('Despesas', 'R\$ 8.200,00', Colors.red.shade700)),
              ],
            ),
            SizedBox(height: 12),
            _buildFinanceCard('Saldo', 'R\$ 4.300,00', Color(0xFF8B4513), isFullWidth: true),
            SizedBox(height: 24),

            // Resumo Diário Section
            Text(
              'Resumo Diário',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Vendas no Balcão', 'R\$ 2.300,00')),
                SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Vendas por Entrega', 'R\$ 1.500,00')),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Despesas', 'R\$ 800,00')),
                SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Recibos', 'R\$ 1.200,00')),
              ],
            ),
            SizedBox(height: 24),

            // Acesso Rápido Section
            Text(
              'Acesso Rápido',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildQuickAccessButton(Icons.add, 'Criar Produto')),
                SizedBox(width: 12),
                Expanded(child: _buildQuickAccessButton(Icons.bar_chart, 'Relatórios')),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildQuickAccessButton(Icons.receipt_long_sharp, 'Resumo de caixa')),
                SizedBox(width: 12),
                Expanded(child: _buildQuickAccessButton(Icons.receipt, 'Receber Pagamento')),
              ],
            ),
            SizedBox(height: 12),
            _buildQuickAccessButton(Icons.attach_money, 'PDV', isFullWidth: true),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFF2D2419),
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Color(0xFF1A1A1A),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, color: Colors.orange, size: 30),
                  SizedBox(width: 8),
                  Text(
                    'PedeAi',
                    style: TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Text('ERP', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.inventory, 'Gestão de Produtos'),
                _buildDrawerItem(Icons.shopping_cart, 'Compras e Fornecedores'),
                _buildDrawerItem(Icons.warehouse, 'Gestão de Estoque'),
                _buildDrawerItem(Icons.people, 'Vendas e Clientes'),
                _buildDrawerItem(Icons.attach_money, 'Financeiro'),
                _buildDrawerItem(Icons.bar_chart, 'Relatórios'),
                _buildDrawerItem(Icons.settings, 'Configurações'),
                Divider(color: Colors.grey.shade600, thickness: 1),
                _buildDrawerItem(Icons.exit_to_app, 'Sair'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  // Fluxo de Caixa
  Widget _buildFinanceCard(String title, String value, Color color, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  //resumo diário
  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String title, {bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A3429),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          // Adicione esta condição para navegar quando for o botão "Criar Produto"
          if (title == 'Criar Produto') {
            Navigator.of(context).pushNamed('/cadastro-produto', arguments: null);
          }

          /*if (title == 'Registrar Produtos') {
          }*/
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
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
