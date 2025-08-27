import 'package:flutter/material.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/utils/app_notify.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

const double _gapXs = 6;
const double _gapSm = 8;
const double _gapMd = 12;
const double _gapLg = 16;

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});
  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  final Produtocontroller _produtoController = Produtocontroller();
  final TextEditingController _searchCtrl = TextEditingController();

  String _filter = 'Todos';
  bool _loading = true;
  String _error = '';
  List<Produto> _produtos = [];
  List<Produto> _filtrados = [];

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
      final dados = await _produtoController.listagemSimplesDeProdutos();
      _produtos = List.from(dados);
      _applyFilter();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar produtos: $e';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    var base = List<Produto>.from(_produtos);
    if (_filter == 'Ativos') {
      base = base.where((p) => p.ativo == true).toList();
    } else if (_filter == 'Inativos') {
      base = base.where((p) => p.ativo == false).toList();
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      base = base.where((p) =>
          p.descricao.toLowerCase().contains(q) ||
          p.codigo.toLowerCase().contains(q)).toList();
    }
    setState(() => _filtrados = base);
  }

  // Toggle de status com "Desfazer", padrão Categorias
  Future<void> _toggleAtivo(Produto p) async {
    final novoAtivo = !(p.ativo ?? true);
    try {
      await _produtoController.atualizarStatusProduto({
        'produto_id_public': p.produtoIdPublic,
        'ativo': novoAtivo,
      });

      if (!mounted) return;
      AppNotify.info(
        context,
        'Produto "${p.descricao}" ${novoAtivo ? 'ativado' : 'desativado'}.',
        actionLabel: 'Desfazer',
        onAction: () async {
          try {
            await _produtoController.atualizarStatusProduto({
              'produto_id_public': p.produtoIdPublic,
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      initialIndex: 2, // Todos
      child: Scaffold(
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
            'Lista de Produtos',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: cs.onSurface),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorColor: cs.primary,
            labelColor: cs.onSurface,
            unselectedLabelColor: cs.onSurface.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            onTap: (i) {
              final map = {0: 'Ativos', 1: 'Inativos', 2: 'Todos'};
              _filter = map[i]!;
              _applyFilter();
            },
            tabs: const [
              Tab(text: 'Ativos'),
              Tab(text: 'Inativos'),
              Tab(text: 'Todos'),
            ],
          ),
        ),

        drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
        bottomNavigationBar: AppNavBar(
          currentRoute: ModalRoute.of(context)?.settings.name,
        ),

        body: Column(
          children: [
            // Busca
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar produtos',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            Expanded(child: _buildContent(cs)),

            // CTA fixo
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final ok = await Navigator.of(context)
                        .pushNamed('/cadastro-produto', arguments: null);
                    if (ok == true) _load();
                  },
                  child: const Text('Cadastrar Novo Produto'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
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
              Icon(Icons.error_outline, color: cs.primary, size: 56),
              const SizedBox(height: _gapSm),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: _gapSm),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                child: Text('Tentar novamente',
                    style: TextStyle(color: cs.onPrimary)),
              ),
            ],
          ),
        ),
      );
    }
    if (_filtrados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _searchCtrl.text.isNotEmpty
                ? 'Nenhum produto encontrado para "${_searchCtrl.text}"'
                : 'Nenhum produto encontrado',
            style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      backgroundColor: cs.surface,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: _filtrados.length,
        separatorBuilder: (_, __) => const SizedBox(height: _gapSm),
        itemBuilder: (context, i) {
          final p = _filtrados[i];
          return _ProductCard(
            produto: p,
            onTap: () async {
              final ok = await Navigator.of(context).pushNamed(
                '/cadastro-produto',
                arguments: p.produtoIdPublic,
              );
              if (ok == true) _load();
            },
            onToggleAtivo: () => _toggleAtivo(p),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.produto,
    required this.onTap,
    required this.onToggleAtivo,
  });

  final Produto produto;
  final VoidCallback onTap;
  final VoidCallback onToggleAtivo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ativo = produto.ativo ?? true;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onToggleAtivo, // mantém o toggle por long press
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // texto à esquerda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código: ${produto.codigo}',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      produto.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // >>> Linha com STATUS antes do preço <<<
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // bolinha de status
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: ativo ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          ativo ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            color: ativo ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text('•',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                            )),
                        Text(
                          'Preço: ${produto.precoFormatado}',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                        Text('•',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                            )),
                        Text(
                          'Estoque: ${produto.estoque} '
                          '${produto.estoque == 1 ? 'unidade' : 'unidades'}',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // thumb à direita
              Container(
                width: 86,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: (produto.image_url != null &&
                        produto.image_url!.isNotEmpty)
                    ? Image.network(
                        produto.image_url!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.broken_image,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      )
                    : Icon(
                        produto.estoque > 0
                            ? Icons.inventory
                            : Icons.inventory_2_outlined,
                        color: produto.estoque > 0
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.5),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
