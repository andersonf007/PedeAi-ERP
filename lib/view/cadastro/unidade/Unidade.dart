import 'package:flutter/material.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/theme/color_tokens.dart'; // BrandColors (verde/laranja)
import 'package:pedeai/controller/unidadeController.dart'; // ajuste se o caminho/nome forem outros
import 'package:pedeai/model/unidade.dart';               // ajuste se o caminho/nome forem outros

/// Tela de listagem/gestão de Unidades.
/// - Busca em memória (nome/sigla)
/// - Chip "Ativo/Inativo" que alterna status ao toque
/// - Ícone de lápis para editar
/// - Long-press no card para excluir
/// - Formulário em bottom-sheet
/// - Cores via Theme (ColorScheme)
class UnidadesPage extends StatefulWidget {
  const UnidadesPage({Key? key}) : super(key: key);

  @override
  State<UnidadesPage> createState() => _UnidadesPageState();
}

class _UnidadesPageState extends State<UnidadesPage> {
  // Controllers
  final Unidadecontroller _unidadeController = Unidadecontroller(); // <— ajuste o nome se diferente
  final TextEditingController _searchCtrl = TextEditingController();

  // Estado
  bool _loading = true;
  String _error = '';
  List<Unidade> _unidades = [];
  List<Unidade> _filtradas = [];

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

  /// Carrega unidades do backend e aplica o filtro atual
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      // LISTAR — ajuste o nome do método se for diferente:
      final lista = await _unidadeController.listarUnidade();
      _unidades = List.from(lista);
      _applyFilter();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar unidades: $e';
        _loading = false;
      });
    }
  }

  /// Filtra em memória (nome/sigla)
  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final base = List<Unidade>.from(_unidades);
    if (q.isEmpty) {
      setState(() => _filtradas = base);
      return;
    }
    setState(() {
      _filtradas = base.where((u) {
        final nome = (u.nome ?? '').toLowerCase();
        final sigla = (u.sigla ?? '').toLowerCase();
        return nome.contains(q) || sigla.contains(q);
      }).toList();
    });
  }

  /// Abre bottom-sheet para criar/editar
  Future<void> _openUnidadeSheet({Unidade? unidade}) async {
    final cs = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _UnidadeFormSheet(
        existente: unidade,
        onSalvar: (payload) async {
          try {
            if (unidade == null) {
              // CRIAR — ajuste se o método tiver outro nome
              await _unidadeController.inserirUnidade(payload);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Unidade criada com sucesso!'),
                  backgroundColor: cs.primary,
                ),
              );
            } else {
              // ATUALIZAR — ajuste se o método tiver outro nome
              final toUpdate = {'id': unidade.id, ...payload};
              await _unidadeController.atualizarUnidade(toUpdate);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Unidade atualizada com sucesso!'),
                  backgroundColor: cs.primary,
                ),
              );
            }
            if (!mounted) return;
            Navigator.pop(context, true);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao salvar unidade: $e'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
      ),
    );

    if (result == true) await _load();
  }

  /// Alterna ativo/inativo (apenas o boolean)
  Future<void> _toggleAtivo(Unidade u) async {
    final cs = Theme.of(context).colorScheme;
    try {
      final novoAtivo = !(u.ativo ?? true);
      // ATUALIZAR STATUS — ajuste se o método tiver outro nome
      await _unidadeController.atualizarStatusUnidade({'id': u.id, 'ativo': novoAtivo});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(novoAtivo ? 'Unidade ativada' : 'Unidade desativada'),
          backgroundColor: cs.primary,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alterar status: $e'), backgroundColor: cs.error),
      );
    }
  }

  /// Confirma e exclui (long-press no card)
  Future<void> _confirmDelete(Unidade u) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Excluir unidade', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Tem certeza que deseja excluir "${u.nome}"?',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
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
        // DELETAR — ajuste se o método tiver outro nome
        await _unidadeController.deletarUnidade(u.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Unidade excluída com sucesso.'), backgroundColor: cs.primary),
        );
        await _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: cs.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: cs.onBackground),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Unidades',
            style: TextStyle(color: cs.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _load, icon: Icon(Icons.refresh, color: cs.onBackground)),
        ],
      ),
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar unidade (nome ou sigla)...',
                hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.5)),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: cs.onSurface),
            ),
          ),

          // Lista
          Expanded(child: _buildContent()),

          // Botão fixo
          SafeArea(
            top: false,
            minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => _openUnidadeSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Cadastrar Nova Unidade',
                    style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
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
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(cs.primary)));
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
              Text(_error, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                child: Text('Tentar novamente', style: TextStyle(color: cs.onPrimary)),
              ),
            ],
          ),
        ),
      );
    }
    if (_filtradas.isEmpty) {
      return Center(
        child: Text('Nenhuma unidade encontrada', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
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

  /// Item da lista: Nome + (sigla) | Chip status | Lápis
  Widget _buildItem(Unidade u, int index) {
    final cs = Theme.of(context).colorScheme;
    final ativo = u.ativo ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onLongPress: () => _confirmDelete(u),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            // Texto à esquerda
            Expanded(
              child: Text(
                '${index + 1}. ${u.nome ?? ''}${(u.sigla ?? '').isNotEmpty ? ' (${u.sigla})' : ''}',
                style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),

            // Ações à direita
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusChip(ativo: ativo, onTap: () => _toggleAtivo(u)),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  // lápis branco no dark, cor de destaque no light (igual você usa em Categorias)
                  color: isDark ? Colors.white : cs.primary,
                  onPressed: () => _openUnidadeSheet(unidade: u),
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

/// Chip de status "Ativo/Inativo" (mesma paleta que Categorias)
class _StatusChip extends StatelessWidget {
  final bool ativo;
  final VoidCallback onTap;
  const _StatusChip({required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = ativo ? BrandColors.success700 : BrandColors.warning700; // verde/laranja escuros
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      splashColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.white.withValues(alpha: 0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: const Text('Ativo', // o texto muda abaixo
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Bottom-sheet do formulário (Criar/Editar Unidade)
class _UnidadeFormSheet extends StatefulWidget {
  final Unidade? existente;
  final Future<void> Function(Map<String, dynamic> payload) onSalvar;

  const _UnidadeFormSheet({Key? key, required this.existente, required this.onSalvar}) : super(key: key);

  @override
  State<_UnidadeFormSheet> createState() => _UnidadeFormSheetState();
}

class _UnidadeFormSheetState extends State<_UnidadeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _siglaCtrl = TextEditingController();

  // valores originais para detectar mudanças
  late String _initialNome;
  late String _initialSigla;
  bool _dirty = false;

  bool get _isEdicao => widget.existente != null;

  @override
  void initState() {
    super.initState();
    _initialNome = widget.existente?.nome ?? '';
    _initialSigla = widget.existente?.sigla ?? '';

    _nomeCtrl.text = _initialNome;
    _siglaCtrl.text = _initialSigla;

    _nomeCtrl.addListener(_recalcDirty);
    _siglaCtrl.addListener(_recalcDirty);
  }

  @override
  void dispose() {
    _nomeCtrl.removeListener(_recalcDirty);
    _siglaCtrl.removeListener(_recalcDirty);
    _nomeCtrl.dispose();
    _siglaCtrl.dispose();
    super.dispose();
  }

  void _recalcDirty() {
    final nome = _nomeCtrl.text.trim();
    final sigla = _siglaCtrl.text.trim();
    final changed = nome != _initialNome.trim() || sigla != _initialSigla.trim();
    if (changed != _dirty) setState(() => _dirty = changed);
  }

  Future<void> _handleSalvar() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'nome': _nomeCtrl.text.trim(),
      'sigla': _siglaCtrl.text.trim(),
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
          // handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration:
                BoxDecoration(color: cs.onSurface.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(12)),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isEdicao ? 'Atualizar Unidade' : 'Cadastrar Unidade',
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Nome
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nome da Unidade',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomeCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                  decoration: InputDecoration(
                    hintText: _isEdicao ? null : 'Ex.: Quilograma',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  style: TextStyle(color: cs.onSurface),
                ),

                const SizedBox(height: 16),

                // Sigla
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sigla',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _siglaCtrl,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                  decoration: InputDecoration(
                    hintText: _isEdicao ? null : 'Ex.: KG',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  style: TextStyle(color: cs.onSurface),
                ),

                const SizedBox(height: 20),

                // Botão dinâmico (Cancelar quando nada mudou)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: _isEdicao && !_dirty
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.primary, width: 1.5),
                            foregroundColor: cs.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            overlayColor: cs.primary.withValues(alpha: 0.08),
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            overlayColor: cs.onPrimary.withValues(alpha: 0.08),
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
