import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key, this.currentRoute});
  final String? currentRoute;

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  String? _openKey;

  @override
  void initState() {
    super.initState();
    final r = widget.currentRoute ?? '';
    // abre a seção correta com base na rota atual
    if (r.startsWith('/pdv')) _openKey = 'venda';
    if (r.startsWith('/listProdutos') ||
        r.startsWith('/listCategorias') ||
        r.startsWith('/cadastro-unidade') ||
        r.startsWith('/listUsuarios'))
      _openKey = 'cadastro';
  }
Future<void> _confirmAndLogout() async {
  final cs = Theme.of(context).colorScheme;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cs.surface,
      title: Text(
        'Sair da conta?',
        style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Você será desconectado do PedeAi.',
        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.75)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancelar', style: TextStyle(color: cs.onSurface)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Sair'),
        ),
      ],
    ),
  );

  if (ok != true) return;

  await _doLogout();
}

Future<void> _doLogout() async {
  try {
    // 1) limpa sessão local (ajuste as chaves conforme seu app)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario');
    await prefs.remove('empresa_id');
    // Se você guardar mais coisas, remova aqui ou use prefs.clear();

    if (!mounted) return;

    // 2) fecha o Drawer, se ainda estiver aberto
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop(); // fecha o Drawer
    }

    // 3) navega para login limpando a pilha de rotas
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  } catch (e) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Falha ao sair: $e', style: TextStyle(color: cs.onError)),
        backgroundColor: cs.error,
      ),
    );
  }
}

  void _toggle(String k) => setState(() => _openKey = _openKey == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current =
        widget.currentRoute ?? (ModalRoute.of(context)?.settings.name ?? '');

    return Drawer(
      child: SafeArea(
        child: Container(
          color: cs.background,
          child: Column(
            children: [
              // Cabeçalho
              Container(
                height: 96,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: cs.surface),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: cs.primary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'PedeAi',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ERP',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.2)),

              // Conteúdo com scroll
              Expanded(
                child: Scrollbar(
                  thickness: 3,
                  radius: const Radius.circular(8),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // VENDA
                      _NavSection(
                        keyValue: 'venda',
                        title: 'Venda',
                        icon: Icons.shopping_cart_outlined,
                        isOpen: _openKey == 'venda',
                        onToggle: () => _toggle('venda'),
                        children: [
                          _NavItem(
                            icon: Icons.point_of_sale,
                            label: 'PDV',
                            selected: current == '/pdv',
                            onTap: () => _go(context, '/pdv'),
                          ),
                        ],
                      ),

                      // CADASTRO
                      _NavSection(
                        keyValue: 'cadastro',
                        title: 'Cadastro',
                        icon: Icons.app_registration,
                        isOpen: _openKey == 'cadastro',
                        onToggle: () => _toggle('cadastro'),
                        children: [
                          _NavItem(
                            icon: Icons.category,
                            label: 'Categoria',
                            selected: current == '/listCategorias',
                            onTap: () => _go(context, '/listCategorias'),
                          ),
                          _NavItem(
                            icon: Icons.payment,
                            label: 'Formas de Pagamento',
                            selected: current == '/listFormasPagamento',
                            onTap: () => _go(context, '/listFormasPagamento'),
                          ),
                          _NavItem(
                            icon: Icons.inventory,
                            label: 'Produto',
                            selected: current == '/listProdutos',
                            onTap: () => _go(context, '/listProdutos'),
                          ),
                          _NavItem(
                            icon: Icons.straighten,
                            label: 'Unidade',
                            selected: current == '/listUnidades',
                            onTap: () => _go(context, '/listUnidades'),
                          ),
                          _NavItem(
                            icon: Icons.person,
                            label: 'Usuário',
                            selected: current == '/listUsuarios',
                            onTap: () => _go(context, '/listUsuarios'),
                          ),
                        ],
                      ),

                      // ENTRADAS SOLTAS
                      _PlainEntry(
                        icon: Icons.warehouse,
                        label: 'Estoque',
                        selected: current == '/estoque',
                        onTap: () => _go(context, '/estoque'),
                      ),
                      _PlainEntry(
                        icon: Icons.point_of_sale,
                        label: 'Caixa',
                        // se não tiver rota própria, usa o PDV
                        selected: current == '/caixa',
                        onTap: () => _go(context, '/pdv'),
                      ),
                      _PlainEntry(
                        icon: Icons.attach_money,
                        label: 'Financeiro',
                        selected: current == '/financeiro',
                        onTap: () => _go(context, '/financeiro'),
                      ),
                      _PlainEntry(
                        icon: Icons.settings,
                        label: 'Configurações',
                        selected: current == '/config',
                        onTap: () => _go(context, '/config'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Rodapé fixo
              Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.2)),
              _PlainEntry(
                icon: Icons.exit_to_app,
                label: 'Sair',
                danger: true,
                onTap: _confirmAndLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    final here = ModalRoute.of(context)?.settings.name;
    if (here == route) return;
    Navigator.of(context).pushNamed(route, arguments: null);
  }
}

// ---------- componentes visuais ----------

class _NavSection extends StatelessWidget {
  const _NavSection({
    required this.keyValue,
    required this.title,
    required this.icon,
    required this.isOpen,
    required this.onToggle,
    required this.children,
  });

  final String keyValue;
  final String title;
  final IconData icon;
  final bool isOpen;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconTitleColor = cs.onSurface;
    //final borderColor = cs.onSurface.withValues(alpha: 0.35);
    final borderColor = cs.primary;

    final header = InkWell(
      onTap: onToggle,
      overlayColor: MaterialStatePropertyAll(
        cs.onSurface.withValues(alpha: 0.06),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 48,
        decoration: BoxDecoration(
          color: isOpen ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isOpen ? Border.all(color: borderColor, width: 1.2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconTitleColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: iconTitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.expand_more, color: iconTitleColor),
            ),
          ],
        ),
      ),
    );

    if (!isOpen) return header;

    return Column(
      children: [
        header,
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: children
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: w,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = selected ? cs.onPrimary : cs.primary; // submenus laranja
    final textColor = selected ? cs.onPrimary : cs.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        titleAlignment: ListTileTitleAlignment.center,
      ),
    );
  }
}

class _PlainEntry extends StatelessWidget {
  const _PlainEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tileColor = selected ? cs.primary : Colors.transparent;
    final iconColor = danger
        ? Colors.redAccent
        : (selected ? cs.onPrimary : cs.onSurface);
    final textColor = iconColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: tileColor,
        leading: Icon(icon, color: iconColor),
        title: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
