import 'package:flutter/material.dart';
import 'package:pedeai/controller/categoriaController.dart';
import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/theme/color_tokens.dart';
import 'package:pedeai/utils/app_notify.dart';
// ⬇️ importe a barra de navegação
import 'package:pedeai/app_nav_bar.dart';

/// Tela de listagem/gestão de Categorias.
/// - Busca em memória
/// - Chip "Ativo/Inativo" que alterna status ao toque
/// - Ícone de lápis para editar
/// - Long-press no card para excluir
/// - Formulário em bottom-sheet
/// - Cores via Theme (ColorScheme), usando surface/onSurface
class CategoriasPage extends StatefulWidget {
  const CategoriasPage({Key? key}) : super(key: key);

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  // Controllers
  final Categoriacontroller _categoriaController = Categoriacontroller();
  final TextEditingController _searchCtrl = TextEditingController();

  // Estado local
  bool _loading = true;
  String _error = '';
  List<Categoria> _categorias = [];
  List<Categoria> _filtradas = [];

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

  /// Carrega categorias do backend e aplica o filtro atual
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final lista = await _categoriaController.listarCategoria();
      _categorias = List.from(lista);
      _applyFilter();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar categorias: $e';
        _loading = false;
      });
      AppNotify.error(context, 'Falha ao carregar: $e');
    }
  }

  /// Filtra categorias em memória com base no texto da busca
  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final base = List<Categoria>.from(_categorias);
    if (q.isEmpty) {
      setState(() => _filtradas = base);
      return;
    }
    setState(() {
      _filtradas = base.where((c) {
        final nome = c.nome.toLowerCase();
        final desc = (c.descricao ?? '').toLowerCase();
        return nome.contains(q) || desc.contains(q);
      }).toList();
    });
  }

  /// Abre o bottom-sheet de criação/edição
  Future<void> _openCategoriaSheet({Categoria? categoria}) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CategoriaFormSheet(
        existente: categoria,
        onSalvar: (payload) async {
          try {
            if (categoria == null) {
              // Criar
              await _categoriaController.inserirCategoria(payload);
              if (!mounted) return;
              AppNotify.success(context, 'Categoria "${payload['nome']}" criada.');
            } else {
              // Atualizar
              final mapAtualizar = {'id': categoria.id, ...payload};
              await _categoriaController.atualizarCategoria(mapAtualizar);
              if (!mounted) return;
              AppNotify.success(context, 'Categoria "${payload['nome']}" atualizada.');
            }
            if (!mounted) return;
            Navigator.pop(context, true);
          } catch (e) {
            if (!mounted) return;
            AppNotify.error(context, 'Erro ao salvar categoria: $e');
          }
        },
      ),
    );

    if (ok == true) {
      await _load();
    }
  }

  /// Alterna o status ativo/inativo
  Future<void> _toggleAtivo(Categoria c) async {
    try {
      final novoAtivo = !(c.ativo ?? true);

      await _categoriaController.atualizarStatusCategoria({
        'id': c.id,
        'ativo': novoAtivo,
      });
      if (!mounted) return;

      // Notificação com "Desfazer"
      AppNotify.info(
        context,
        'Categoria "${c.nome}" ${novoAtivo ? 'ativada' : 'desativada'}.',
        actionLabel: 'Desfazer',
        onAction: () async {
          try {
            await _categoriaController.atualizarStatusCategoria({
              'id': c.id,
              'ativo': !novoAtivo,
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

  /// Confirma e exclui categoria
  Future<void> _confirmDelete(Categoria c) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          'Excluir categoria',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${c.nome}"?',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: cs.onSurface)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir', style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        // Se quiser realmente excluir, descomente a linha abaixo:
        // await _categoriaController.deletarCategoria(c.id);
        if (!mounted) return;
        AppNotify.success(context, 'Categoria "${c.nome}" excluída.');
        await _load();
      } catch (e) {
        if (!mounted) return;
        AppNotify.error(context, 'Erro ao excluir: $e');
      }
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
          'Categorias',
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
      // Drawer lateral
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),

      // ⬇️ Barra de navegação inferior adicionada
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
              decoration: const InputDecoration(
                hintText: 'Buscar categoria...',
                prefixIcon: Icon(Icons.search),
              ),
              style: TextStyle(color: cs.onSurface),
            ),
          ),

          // Lista
          Expanded(child: _buildContent()),

          // Botão fixo (SafeArea)
          SafeArea(
            top: false,
            minimum: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => _openCategoriaSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cadastrar Nova Categoria',
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

  /// Constrói o conteúdo principal de acordo com estado de carregamento/erro
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
    if (_filtradas.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma categoria encontrada',
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
        itemBuilder: (ctx, i) => _buildItem(_filtradas[i], i),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: _filtradas.length,
      ),
    );
  }

  /// Card de item da lista
  Widget _buildItem(Categoria c, int index) {
    final cs = Theme.of(context).colorScheme;
    final ativo = c.ativo ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onLongPress: () => _confirmDelete(c),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Texto à esquerda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${c.nome}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((c.descricao ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      c.descricao!.trim(),
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Ações à direita
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusChip(ativo: ativo, onTap: () => _toggleAtivo(c)),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  color: isDark ? Colors.white : cs.primary,
                  onPressed: () => _openCategoriaSheet(categoria: c),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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

/// Chip de status "Ativo/Inativo" com toque para alternar
class _StatusChip extends StatelessWidget {
  final bool ativo;
  final VoidCallback onTap;
  const _StatusChip({required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = ativo ? BrandColors.success700 : BrandColors.warning700;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      splashColor: Colors.white.withOpacity(0.06),
      highlightColor: Colors.white.withOpacity(0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          ativo ? 'Ativo' : 'Inativo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet do formulário (criar/editar categoria)
class _CategoriaFormSheet extends StatefulWidget {
  final Categoria? existente;
  final Future<void> Function(Map<String, dynamic> payload) onSalvar;

  const _CategoriaFormSheet({
    Key? key,
    required this.existente,
    required this.onSalvar,
  }) : super(key: key);

  @override
  State<_CategoriaFormSheet> createState() => _CategoriaFormSheetState();
}

class _CategoriaFormSheetState extends State<_CategoriaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late String _initialNome;
  late String _initialDesc;
  bool _dirty = false;

  bool get _isEdicao => widget.existente != null;

  @override
  void initState() {
    super.initState();
    _initialNome = widget.existente?.nome ?? '';
    _initialDesc = widget.existente?.descricao ?? '';

    _nomeCtrl.text = _initialNome;
    _descCtrl.text = _initialDesc;

    _nomeCtrl.addListener(_recalcDirty);
    _descCtrl.addListener(_recalcDirty);
  }

  @override
  void dispose() {
    _nomeCtrl.removeListener(_recalcDirty);
    _descCtrl.removeListener(_recalcDirty);
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _recalcDirty() {
    final nome = _nomeCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final changed = nome != _initialNome.trim() || desc != _initialDesc.trim();
    if (changed != _dirty) setState(() => _dirty = changed);
  }

  Future<void> _handleSalvar() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'nome': _nomeCtrl.text.trim(),
      'descricao': _descCtrl.text.trim(),
    };
    await widget.onSalvar(payload);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Título
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isEdicao ? 'Atualizar Categoria' : 'Cadastrar Categoria',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nome da Categoria',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomeCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                  decoration: InputDecoration(
                    hintText: _isEdicao ? null : 'Insira o nome da categoria...',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(color: cs.onSurface),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Descrição (opcional)',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Ex: categorias usadas no balcão…',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(color: cs.onSurface),
                ),

                const SizedBox(height: 20),

                // Botão dinâmico
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: _isEdicao && !_dirty
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.primary, width: 1.5),
                            foregroundColor: cs.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overlayColor: cs.primary.withValues(alpha: 0.08), // hover/pressed
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overlayColor: cs.onPrimary.withValues(alpha: 0.08), // hover/pressed
                          ),
                          onPressed: _handleSalvar,
                          child: const Text('Salvar'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
