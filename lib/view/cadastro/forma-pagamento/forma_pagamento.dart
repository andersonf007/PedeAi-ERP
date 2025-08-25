import 'package:flutter/material.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/theme/color_tokens.dart';

// AJUSTE estes imports para os seus caminhos reais:
import 'package:pedeai/controller/formaPagamentoController.dart';
import 'package:pedeai/model/forma_pagamento.dart';

// Notificações
import 'package:pedeai/utils/app_notify.dart';

// ⬇️ Barra de navegação inferior
import 'package:pedeai/app_nav_bar.dart';

class FormasPagamentoPage extends StatefulWidget {
  const FormasPagamentoPage({Key? key}) : super(key: key);

  @override
  State<FormasPagamentoPage> createState() => _FormasPagamentoPageState();
}

class _FormasPagamentoPageState extends State<FormasPagamentoPage> {
  // Controllers
  final FormaPagamentocontroller _fpController = FormaPagamentocontroller();
  final TextEditingController _searchCtrl = TextEditingController();

  // Estado local
  bool _loading = true;
  String _error = '';
  List<FormaPagamento> _itens = [];
  List<FormaPagamento> _filtrados = [];

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

  /// Carrega do backend e aplica o filtro atual
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final lista = await _fpController.listarFormaPagamento();
      _itens = List.from(lista);
      _applyFilter();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar formas de pagamento: $e';
        _loading = false;
      });
      AppNotify.error(context, 'Falha ao carregar: $e');
    }
  }

  /// Filtra em memória pelo texto da busca
  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final base = List<FormaPagamento>.from(_itens);
    if (q.isEmpty) {
      setState(() => _filtrados = base);
      return;
    }
    setState(() {
      _filtrados = base.where((f) {
        final nome = (f.nome ?? '').toLowerCase();
        final desc = (f.descricao ?? '').toLowerCase();
        return nome.contains(q) || desc.contains(q);
      }).toList();
    });
  }

  /// Bottom-sheet de criação/edição
  Future<void> _openSheet({FormaPagamento? existente}) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FormaPagamentoFormSheet(
        existente: existente,
        onSalvar: (payload) async {
          try {
            if (existente == null) {
              await _fpController.inserirFormaPagamento(payload);
              if (!mounted) return;
              AppNotify.success(context, 'Forma "${payload['nome']}" criada.');
            } else {
              final dados = {'id': existente.id, ...payload};
              await _fpController.atualizarFormaPagamento(dados);
              if (!mounted) return;
              AppNotify.success(context, 'Forma "${payload['nome']}" atualizada.');
            }
            if (!mounted) return;
            Navigator.pop(context, true);
          } catch (e) {
            if (!mounted) return;
            AppNotify.error(context, 'Erro ao salvar forma: $e');
          }
        },
      ),
    );

    if (ok == true) {
      await _load();
    }
  }

  /// Alterna o status ativo/inativo (com ação de desfazer)
  Future<void> _toggleAtivo(FormaPagamento f) async {
    try {
      final novo = !(f.ativo ?? true);
      await _fpController.atualizarStatusFormaPagamento({'id': f.id, 'ativo': novo});
      if (!mounted) return;

      AppNotify.info(
        context,
        'Forma "${f.nome}" ${novo ? 'ativada' : 'desativada'}.',
        actionLabel: 'Desfazer',
        onAction: () async {
          try {
            await _fpController.atualizarStatusFormaPagamento({'id': f.id, 'ativo': !novo});
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

  /// Confirmação e exclusão
  Future<void> _confirmDelete(FormaPagamento f) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Excluir forma de pagamento', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Tem certeza que deseja excluir "${f.nome}"?', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: cs.onSurface))),
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
        await _fpController.deletarFormaPagamento(f.id!);
        if (!mounted) return;
        AppNotify.success(context, 'Forma "${f.nome}" excluída.');
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
      backgroundColor: cs.surface, // alinhado ao resto das telas
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
        title: Text('Formas de Pagamento', style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _load, icon: Icon(Icons.refresh, color: cs.onSurface))],
      ),
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),

      // ⬇️ Barra de navegação inferior
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
                hintText: 'Buscar forma de pagamento...',
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
            minimum: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => _openSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Cadastrar Nova Forma', style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renderiza conteúdo conforme estado
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
    if (_filtrados.isEmpty) {
      return Center(child: Text('Nenhuma forma de pagamento encontrada', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))));
    }

    return RefreshIndicator(
      color: cs.primary,
      backgroundColor: cs.surface,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemBuilder: (ctx, i) => _buildItem(_filtrados[i], i),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: _filtrados.length,
      ),
    );
  }

  /// Card de item
  Widget _buildItem(FormaPagamento f, int index) {
    final cs = Theme.of(context).colorScheme;
    final ativo = f.ativo ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onLongPress: () => _confirmDelete(f),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Texto à esquerda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}. ${f.nome ?? ''}', style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  if ((f.descricao ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      f.descricao!.trim(),
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Ações
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusChip(ativo: ativo, onTap: () => _toggleAtivo(f)),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  color: isDark ? Colors.white : cs.primary,
                  onPressed: () => _openSheet(existente: f),
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

/// Chip de status com toque
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
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        alignment: Alignment.center,
        child: Text(
          ativo ? 'Ativo' : 'Inativo',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Bottom-sheet: criar/editar forma de pagamento
class _FormaPagamentoFormSheet extends StatefulWidget {
  final FormaPagamento? existente;
  final Future<void> Function(Map<String, dynamic> payload) onSalvar;

  const _FormaPagamentoFormSheet({Key? key, required this.existente, required this.onSalvar}) : super(key: key);

  @override
  State<_FormaPagamentoFormSheet> createState() => _FormaPagamentoFormSheetState();
}

class _FormaPagamentoFormSheetState extends State<_FormaPagamentoFormSheet> {
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
            decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(12)),
          ),
          // Título
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isEdicao ? 'Atualizar Forma de Pagamento' : 'Cadastrar Forma de Pagamento',
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
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
                  child: Text('Nome', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9), fontSize: 12)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomeCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                  decoration: InputDecoration(
                    hintText: _isEdicao ? null : 'Ex.: Dinheiro, Cartão de Crédito…',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  style: TextStyle(color: cs.onSurface),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Descrição (opcional)', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9), fontSize: 12)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Algum detalhe sobre a forma…',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
