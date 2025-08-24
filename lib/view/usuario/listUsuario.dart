import 'package:flutter/material.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/usuario.dart';
import 'cadastroUsuario.dart';

class ListUsuarioPage extends StatefulWidget {
  @override
  _ListUsuarioPageState createState() => _ListUsuarioPageState();
}

class _ListUsuarioPageState extends State<ListUsuarioPage> {
  int _selectedIndex = 4;
  final Usuariocontroller usuariocontroller = Usuariocontroller();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() => _isLoading = true);
    final usuarios = await usuariocontroller.listarUsuario();
    setState(() {
      _usuarios = usuarios;
      _isLoading = false;
    });
  }

  void _abrirCadastroUsuario([Usuario? usuario]) async {
    await Navigator.of(context).pushNamed('/cadastro-usuario', arguments: usuario);
    _carregarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        centerTitle: true,
        title: Text(
          'Lista de Usuários',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarUsuarios,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
          : _usuarios.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, color: Colors.white54, size: 64),
                  SizedBox(height: 16),
                  Text('Nenhum usuário encontrado', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: Color(0xFF2D2419), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.person, color: Colors.orange, size: 28),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.nome ?? '',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(usuario.email ?? '', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: usuario.ativo == true ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          usuario.ativo == true ? 'Ativo' : 'Inativo',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange, size: 20),
                        onPressed: () => _abrirCadastroUsuario(usuario),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirCadastroUsuario(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.orange,
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
        } else if (index == 3) {
          Navigator.of(context).pushNamed('/estoque', arguments: null);
        }else if (index == 4) {
          Navigator.of(context).pushNamed('/listUsuarios', arguments: null);
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Painel'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Vendas'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produtos'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estoque'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuário'),
      ],
    );
  }
}
