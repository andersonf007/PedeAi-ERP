import 'package:flutter/material.dart';
import 'package:pedeai/theme/color_tokens.dart';

/// Barra de navegação inferior (rápida) para as telas principais.
class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.currentRoute});
  final String? currentRoute;

  // Abas em ordem
  static const List<String> _routes = <String>[
    '/home',         // Dashboard
    '/listProdutos', // Produtos
    '/estoque',      // Estoque
    '/pdv',          // Compras/PDV
    '/listUsuarios',       // Perfil/Configurações
  ];

  // Normaliza rotas filhas para a aba “mãe”
  String _normalize(String? route) {
    switch (route) {
      case '/cadastro-produto':
      case '/listProdutos':
        return '/listProdutos';
      case '/estoque':
        return '/estoque';
      case '/pdv':
        return '/pdv';
      case '/listUsuarios':
      case '/cadastro-usuario':
      case '/config':
        return '/listUsuarios';
      case '/listCategorias':
      case '/home':
      default:
        return '/home';
    }
  }

  int _indexFromRoute(String? route) => _routes.indexOf(_normalize(route));

  void _go(BuildContext context, int index) {
    final target = _routes[index];
    final current = _normalize(ModalRoute.of(context)?.settings.name);
    if (current == target) return;
    Navigator.of(context).pushNamedAndRemoveUntil(target, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Paleta do designer (escuro):
    // - fundo: marrom mais escuro
    // - selecionado: branco total
    // - não selecionado: bege apagado
    final background = isDark ? BrandColors.neutral800 : Colors.white;
    final selected = isDark ? Colors.white : BrandColors.neutral900;
    final unselected = isDark ? BrandColors.neutral400 : BrandColors.neutral400;

    final idx = _indexFromRoute(currentRoute);
    final topDivider = (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.10 : 0.06);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border(top: BorderSide(color: topDivider, width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors
                .transparent, // o Container acima cuida do fundo + divisor
            elevation: 0,
            indicatorColor: Colors.transparent, // sem pílula/realce
            iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>(
              (states) => IconThemeData(
                color: states.contains(MaterialState.selected) ? selected : unselected,
              ),
            ),
            labelTextStyle: MaterialStateProperty.resolveWith<TextStyle?>(
              (states) => TextStyle(
                color: states.contains(MaterialState.selected) ? selected : unselected,
                fontWeight:
                    states.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: idx < 0 ? 0 : idx,
            onDestinationSelected: (i) => _go(context, i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Painel',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Produtos',
              ),
              NavigationDestination(
                icon: Icon(Icons.warehouse_outlined),
                selectedIcon: Icon(Icons.warehouse_rounded),
                label: 'Estoque',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Compras',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
