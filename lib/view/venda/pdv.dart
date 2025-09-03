import 'package:flutter/material.dart';
import 'package:pedeai/controller/categoriaController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/model/itemCarrinho.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/view/venda/alterarQuantidadeDialog.dart';
import 'package:pedeai/utils/app_notify.dart';
import 'package:pedeai/app_nav_bar.dart';

/// Helper para substituir withOpacity por withValues(alpha: ...)
extension _Cx on Color {
  Color opa(double a) => withValues(alpha: a);
}

class PDVPage extends StatefulWidget {
  const PDVPage({super.key});

  @override
  State<PDVPage> createState() => _PDVPageState();
}

class _PDVPageState extends State<PDVPage> with SingleTickerProviderStateMixin {
  final Categoriacontroller _categoriaController = Categoriacontroller();
  final Produtocontroller _produtoController = Produtocontroller();

  List<Categoria> _categorias = [];
  List<Produto> _produtos = [];
  List<Produto> _produtosFiltrados = [];
  final List<ItemCarrinho> _carrinho = [];

  int _selectedTab = 0; // 0 = Produtos, 1 = Resumo
  int? _selectedCategoriaId;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  double get subtotal =>
      _carrinho.fold(0.0, (sum, item) => sum + item.valorTotal);
  double desconto = 0.0;
  double get total => subtotal - (subtotal * (desconto / 100));

  double get totalItensCarrinho =>
      _carrinho.fold(0.0, (sum, item) => sum + item.quantidade);

  /// String para exibir quantidade sem ".0" quando inteiro
  String _fmtQtd(num v) {
    final isInt = v == v.roundToDouble();
    if (isInt) return v.toInt().toString();
    // remove sufixo .0 ou ,0 redundante por segurança
    return v.toString().replaceAll(RegExp(r'([.,]0+)$'), '');
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _searchController.addListener(_filtrarProdutos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final categorias = await _categoriaController.listarCategoria();
      final produtos = await _produtoController.listagemSimplesDeProdutos();
      setState(() {
        _categorias = categorias;
        _produtos = produtos;
        _selectedCategoriaId = null;
        _isLoading = false;
      });
      _filtrarProdutos();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppNotify.error(context, 'Erro ao carregar PDV: $e');
    }
  }

  void _filtrarProdutos() {
    final busca = _searchController.text.trim().toLowerCase();
    setState(() {
      _produtosFiltrados = _produtos.where((produto) {
        final matchCategoria =
            _selectedCategoriaId == null ||
            produto.id_categoria == _selectedCategoriaId;
        final matchBusca =
            (produto.descricao ?? '').toLowerCase().contains(busca) ||
            (produto.codigo ?? '').toLowerCase().contains(busca);
        return matchCategoria && (busca.isEmpty || matchBusca);
      }).toList();
    });
  }

  void _selecionarCategoria(int? idCategoria) {
    setState(() => _selectedCategoriaId = idCategoria);
    _filtrarProdutos();
  }

  void _adicionarAoCarrinho(Produto produto) {
    setState(() {
      final i = _carrinho.indexWhere(
        (item) => item.produto.produtoIdPublic == produto.produtoIdPublic,
      );
      if (i >= 0) {
        _carrinho[i].quantidade++;
      } else {
        _carrinho.add(ItemCarrinho(produto: produto));
      }
    });
  }

  void _removerDoCarrinho(int produtoId) {
    setState(() {
      _carrinho.removeWhere(
        (item) => item.produto.produtoIdPublic == produtoId,
      );
    });
  }

  void _alterarQuantidade(int produtoId, double novaQuantidade) {
    setState(() {
      final i = _carrinho.indexWhere(
        (item) => item.produto.produtoIdPublic == produtoId,
      );
      if (novaQuantidade <= 0) {
        if (i >= 0) _removerDoCarrinho(produtoId);
      } else {
        if (i >= 0) {
          _carrinho[i].quantidade = novaQuantidade;
        } else {
          try {
            final produto = _produtos.firstWhere(
              (p) => p.produtoIdPublic == produtoId,
            );
            _carrinho.add(
              ItemCarrinho(produto: produto, quantidade: novaQuantidade),
            );
          } catch (_) {}
        }
      }
    });
  }

  double _getQuantidadeCarrinho(int produtoId) {
    try {
      final item = _carrinho.firstWhere(
        (item) => item.produto.produtoIdPublic == produtoId,
      );
      return item.quantidade;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pedidos',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (_) => false),
        ),
        // Sem ações: removido ícone de carrinho conforme solicitado
      ),
      bottomNavigationBar: AppNavBar(
        currentRoute: ModalRoute.of(context)?.settings.name,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            )
          : Column(
              children: [
                // Tabs
                Container(
                  color: cs.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton('Produtos', 0),
                      _buildTabButton('Resumo', 1, showBadge: true),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),

                // Conteúdo
                Expanded(
                  child: _selectedTab == 0
                      ? _buildProdutosTab(cs, tt)
                      : _buildResumoTab(cs, tt),
                ),

                // Ações fixas por aba
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _selectedTab == 0
                      ? SizedBox(
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
                            onPressed: totalItensCarrinho == 0
                                ? null
                                : () => setState(() => _selectedTab = 1),
                            child: Text(
                              'Ir para o resumo '
                              '${totalItensCarrinho > 0 ? '(${_fmtQtd(totalItensCarrinho)})' : ''}',
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.primary,
                                  side: BorderSide(color: cs.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () =>
                                    setState(() => _selectedTab = 0),
                                child: const Text('Voltar aos produtos'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _buildPagamentoButton(cs)),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String label, int index, {bool showBadge = false}) {
    final cs = Theme.of(context).colorScheme;
    final selected = _selectedTab == index;
    final badgeVisible = showBadge && totalItensCarrinho > 0;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? cs.primary : cs.onSurface.opa(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (badgeVisible) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.error, // vermelho do tema
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmtQtd(totalItensCarrinho),
                  style: TextStyle(
                    color: cs.onError,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProdutosTab(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Busca
          TextField(
            controller: _searchController,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Buscar produto',
              hintStyle: TextStyle(color: cs.onSurface.opa(0.6)),
              prefixIcon: Icon(Icons.search, color: cs.onSurface.opa(0.6)),
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Categorias
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoriaChip(
                  cs,
                  'Todos',
                  _selectedCategoriaId == null,
                  onTap: () => _selecionarCategoria(null),
                ),
                ..._categorias.map(
                  (c) => _categoriaChip(
                    cs,
                    c.nome ?? '',
                    _selectedCategoriaId == c.id,
                    onTap: () => _selecionarCategoria(c.id),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid de produtos
          Expanded(
            child: RefreshIndicator(
              color: cs.primary,
              backgroundColor: cs.surface,
              onRefresh: _carregarDados,
              child: GridView.builder(
                itemCount: _produtosFiltrados.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final produto = _produtosFiltrados[index];
                  final quantidade =
                      _getQuantidadeCarrinho(produto.produtoIdPublic!);

                  return Builder(
                    builder: (itemContext) => GestureDetector(
                      onTap: () => _adicionarAoCarrinho(produto),
                      onLongPress: () async {
                        final box =
                            itemContext.findRenderObject() as RenderBox;
                        final offset = box.localToGlobal(Offset.zero);
                        const menuWidth = 180.0;
                        const menuHeight = 140.0;
                        final screen = MediaQuery.of(context).size;
                        double left = offset.dx + (box.size.width / 2);
                        double top = offset.dy + (box.size.height / 2);
                        if (left < 8) left = 8;
                        if (left + menuWidth > screen.width) {
                          left = screen.width - menuWidth - 8;
                        }
                        if (top + menuHeight > screen.height) {
                          top = screen.height - menuHeight - 8;
                        }

                        final selected = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            left,
                            top,
                            left + menuWidth,
                            top + menuHeight,
                          ),
                          items: const [
                            PopupMenuItem(
                              value: 'quantidade',
                              child: Text('Quantidade'),
                            ),
                          ],
                        );

                        if (selected == 'quantidade') {
                          final quantidadeAtual =
                              _getQuantidadeCarrinho(
                                  produto.produtoIdPublic!);
                          final novaQuantidade = await showDialog<double>(
                            context: context,
                            builder: (_) => QuantidadeDialog(
                              quantidadeAtual: quantidadeAtual,
                              nomeProduto: produto.descricao ?? '',
                              precoUnitario: produto.preco ?? 0.0,
                            ),
                          );
                          if (novaQuantidade != null) {
                            _alterarQuantidade(
                                produto.produtoIdPublic!, novaQuantidade);
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surface,
                              border: Border.all(
                                color: cs.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        (produto.image_url.isNotEmpty)
                                            ? Image.network(
                                                produto.image_url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                  Icons.fastfood,
                                                  color: cs.primary,
                                                  size: 32,
                                                ),
                                              )
                                            : Container(
                                                color: cs.surfaceVariant,
                                                child: Icon(
                                                  Icons.fastfood,
                                                  color: cs.primary,
                                                  size: 32,
                                                ),
                                              ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Text(
                                      (produto.descricao ?? '')
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 18,
                                  child: Center(
                                    child: Text(
                                      'R\$ ${produto.preco?.toStringAsFixed(2) ?? '0,00'} UN',
                                      style: TextStyle(
                                        color: cs.onSurface.opa(0.7),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (quantidade > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.error, // vermelho do tema
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _fmtQtd(quantidade),
                                  style: TextStyle(
                                    color: cs.onError,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriaChip(
    ColorScheme cs,
    String label,
    bool selected, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? cs.primary : cs.onSurface.opa(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: 32,
                color: cs.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoTab(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: Card(
              color: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _carrinho.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum produto selecionado',
                          style: TextStyle(
                            color: cs.onSurface.opa(0.7),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _carrinho.length,
                        itemBuilder: (_, i) {
                          final item = _carrinho[i];
                          final p = item.produto;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.descricao ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${_fmtQtd(item.quantidade)} UN x R\$ ${p.preco?.toStringAsFixed(2) ?? '0,00'}',
                                        style: TextStyle(
                                          color: cs.onSurface.opa(0.7),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'R\$ ${item.valorTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: cs.error,
                                    size: 20,
                                  ),
                                  onPressed: () => _removerDoCarrinho(
                                      p.produtoIdPublic!),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTotalSection(cs, tt),
        ],
      ),
    );
  }

  Widget _buildTotalSection(ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        _kv(cs, tt, 'Subtotal', 'R\$ ${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 4),
        _kv(
          cs,
          tt,
          'Desconto na venda',
          '- R\$ ${(subtotal * (desconto / 100)).toStringAsFixed(2)}',
          subtle: true,
        ),
        const SizedBox(height: 4),
        _kv(cs, tt, 'Total', 'R\$ ${total.toStringAsFixed(2)}', bold: true),
      ],
    );
  }

  Widget _kv(
    ColorScheme cs,
    TextTheme tt,
    String k,
    String v, {
    bool bold = false,
    bool subtle = false,
  }) {
    final styleBase = tt.bodyMedium?.copyWith(
      color: subtle ? cs.onSurface.opa(0.7) : cs.onSurface,
      fontWeight: bold ? FontWeight.bold : FontWeight.w600,
      fontSize: bold ? 16 : 14,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: styleBase),
        Text(v, style: styleBase),
      ],
    );
  }

  Widget _buildPagamentoButton(ColorScheme cs) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _carrinho.isEmpty
            ? null
            : () {
                final args = {
                  'subtotal': subtotal,
                  'desconto': desconto,
                  'total': total,
                  'carrinho': _carrinho,
                };
                // volta a rota original
                Navigator.of(context).pushNamed('/pagamentoPdv', arguments: args);
              },
        child: const Text('Pagamento'),
      ),
    );
  }
}
