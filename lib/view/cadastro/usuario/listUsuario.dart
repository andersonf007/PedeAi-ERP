import 'package:flutter/material.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/usuario.dart';

// padrão do app
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/theme/color_tokens.dart';
import 'package:pedeai/utils/app_notify.dart';
import 'cadastroUsuario.dart';

class ListUsuarioPage extends StatefulWidget {
  const ListUsuarioPage({Key? key}) : super(key: key);

  @override
  State<ListUsuarioPage> createState() => _ListUsuarioPageState();
}

class _ListUsuarioPageState extends State<ListUsuarioPage> {
  final UsuarioController _usuarioController = UsuarioController();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String _error = '';
  List<Usuario> _usuarios = [];
  List<Usuario> _filtrados = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final lista = await _usuarioController.listarUsuario();
      _usuarios = List<Usuario>.from(lista);
      _applyFilter();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar usuários: $e';
        _loading = false;
      });
      AppNotify.error(context, 'Falha ao carregar: $e');
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final base = List<Usuario>.from(_usuarios);
    if (q.isEmpty) {
      setState(() => _filtrados = base);
      return;
    }
    setState(() {
      _filtrados = base.where((u) {
        final nome = (u.nome ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        return nome.contains(q) || email.contains(q);
      }).toList();
    });
  }

  Future<void> _abrirCadastroUsuario([Usuario? usuario]) async {
    try {
      final ok = await Navigator.of(
        context,
      ).pushNamed<bool>('/cadastro-usuario', arguments: usuario);
      if (ok == true) await _load();
    } catch (_) {
      // fallback sem rota nomeada
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CadastroUsuarioPage(usuario: usuario),
        ),
      );
      if (ok == true) await _load();
    }
  }

  Future<void> _toggleAtivo(Usuario u) async {
    try {
      if (u.uid == null || u.uid!.isEmpty) {
        AppNotify.error(context, 'UID do usuário não encontrado.');
        return;
      }
      final novo = !(u.ativo ?? true);
      await _usuarioController.atualizarUsuario({'uid': u.uid, 'ativo': novo});
      if (!mounted) return;

      AppNotify.info(
        context,
        'Usuário "${u.nome ?? ''}" ${novo ? 'ativado' : 'desativado'}.',
        actionLabel: 'Desfazer',
        onAction: () async {
          try {
            await _usuarioController.atualizarUsuario({
              'uid': u.uid,
              'ativo': !novo,
            });
            if (!mounted) return;
            AppNotify.success(context, 'Alteração desfeita.');
            await _load();
          } catch (e) {
            if (!mounted) return;
            AppNotify.error(context, 'Falha ao desfazer: $e');
          }
        },
      );

      await _load();
    } catch (e) {
      if (!mounted) return;
      AppNotify.error(context, 'Erro ao alterar status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Usuários',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: Icon(Icons.refresh, color: cs.onSurface),
          ),
        ],
      ),
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
      bottomNavigationBar: AppNavBar(
        currentRoute: ModalRoute.of(context)?.settings.name,
      ),

      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail…',
                hintStyle: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: cs.onSurface),
            ),
          ),

          Expanded(child: _buildContent()),

          // Botão fixo
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _abrirCadastroUsuario(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(
                  'Cadastrar Novo Usuário',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(cs.primary),
        ),
      );
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: cs.primary),
              const SizedBox(height: 12),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                child: Text(
                  'Tentar novamente',
                  style: TextStyle(color: cs.onPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_filtrados.isEmpty) {
      return Center(
        child: Text(
          'Nenhum usuário encontrado',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      backgroundColor: cs.surface,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: _filtrados.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _buildItem(_filtrados[i], i),
      ),
    );
  }

  Widget _buildItem(Usuario u, int index) {
    final cs = Theme.of(context).colorScheme;
    final ativo = u.ativo ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _abrirCadastroUsuario(u),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.background,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.person, color: cs.primary),
            ),
            const SizedBox(width: 12),

            // textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${u.nome ?? ''}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u.email ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ações
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusChip(ativo: ativo, onTap: () => _toggleAtivo(u)),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  color: isDark ? Colors.white : cs.primary,
                  onPressed: () => _abrirCadastroUsuario(u),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool ativo;
  final VoidCallback onTap;
  const _StatusChip({required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = ativo ? BrandColors.success700 : BrandColors.warning700;
    final label = ativo ? 'Ativo' : 'Inativo';

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.white.withOpacity(0.06),
        highlightColor: Colors.white.withOpacity(0.04),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
