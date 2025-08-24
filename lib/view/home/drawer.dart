import 'package:flutter/material.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF2D2419),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4A3429)),
              child: Row(
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
            ExpansionTile(
              leading: Icon(Icons.shopping_cart, color: Colors.orange),
              title: Text('Venda', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF4A3429),
              collapsedBackgroundColor: Color(0xFF2D2419),
              children: [
                ListTile(
                  leading: Icon(Icons.shopping_cart_outlined, color: Colors.orange),
                  title: Text('PDV', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pushNamed('/pdv', arguments: null),
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.app_registration, color: Colors.orange),
              title: Text('Cadastro', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF4A3429),
              collapsedBackgroundColor: Color(0xFF2D2419),
              children: [
                ListTile(
                  leading: Icon(Icons.inventory, color: Colors.orange),
                  title: Text('Produto', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pushNamed('/listProdutos', arguments: null),
                ),
                ListTile(
                  leading: Icon(Icons.category, color: Colors.orange),
                  title: Text('Categoria', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.straighten, color: Colors.orange),
                  title: Text('Unidade', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pushNamed('/cadastro-unidade'),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.orange),
                  title: Text('Usuário', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pushNamed('/listUsuarios'),
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.warehouse, color: Colors.orange),
              title: Text('Estoque', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.point_of_sale, color: Colors.orange),
              title: Text('Caixa', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.orange),
              title: Text('Financeiro', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.orange),
              title: Text('Configurações', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            Divider(color: Colors.grey.shade600, thickness: 1),

            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.orange),
              title: Text('Sair', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
