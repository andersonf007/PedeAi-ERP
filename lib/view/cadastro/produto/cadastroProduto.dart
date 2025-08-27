// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pedeai/controller/estoqueController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/controller/categoriaController.dart';
import 'package:pedeai/controller/unidadeController.dart';

import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/model/unidade.dart';

// ⬇️ bottom nav bar do app (você disse que é componente)
import 'package:pedeai/app_nav_bar.dart';

class CadastroProdutoPage extends StatefulWidget {
  final int? produtoId;

  const CadastroProdutoPage({super.key, this.produtoId});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _precoVendaController = TextEditingController();
  final TextEditingController _precoCustoController = TextEditingController();
  final TextEditingController _estoqueController = TextEditingController();
  final TextEditingController _validadeController = TextEditingController();

  final Produtocontroller produtocontroller = Produtocontroller();
  final Categoriacontroller categoriaController = Categoriacontroller();
  final Unidadecontroller unidadeController = Unidadecontroller();
  final Estoquecontroller estoqueController = Estoquecontroller();

  List<Categoria> _categorias = [];
  List<Unidade> _unidades = [];
  Categoria? _selectedCategory;
  Unidade? _selectedUnit;

  bool _isLoading = false;
  bool _isEdicao = false;
  Produto? _produtoEdicao;
  String? imageUrl = '';
  bool _isUploadingImage = false;
  bool _ativo = true;

  // spacing
  static const double _gapSm = 8;
  static const double _gapMd = 16;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _isEdicao = widget.produtoId != null;

    _carregarListasUnidade();
    _carregarListasCategoria();
    if (_isEdicao) {
      _carregarDadosProduto();
    }
  }

  // parse que aceita vírgula e ponto
  double _toDouble(String input) {
    final s = input.trim().replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }

  List<TextInputFormatter> get _decimalInputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}$')),
      ];

  Future<void> _carregarListasUnidade() async {
    try {
      final unidades = await unidadeController.listarUnidade();
      if (!mounted) return;
      setState(() => _unidades = List.from(unidades));
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar listas de unidade: $e',
              style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  Future<void> _carregarListasCategoria() async {
    try {
      final categorias = await categoriaController.listarCategoria();
      if (!mounted) return;
      setState(() => _categorias = List.from(categorias));
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar listas de categoria: $e',
              style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  Future<void> _carregarDadosProduto() async {
    if (widget.produtoId == null) return;
    setState(() => _isLoading = true);

    try {
      final produto =
          await produtocontroller.buscarProdutoPorId(widget.produtoId!);

      if (!mounted) return;

      if (produto != null) {
        if (_categorias.isEmpty) {
          await _carregarListasCategoria();
          if (!mounted) return;
        }
        if (_unidades.isEmpty) {
          await _carregarListasUnidade();
          if (!mounted) return;
        }

        setState(() {
          _produtoEdicao = produto;
          _nomeController.text = produto.descricao;
          _codigoController.text = produto.codigo;
          _precoVendaController.text = produto.preco.toString();
          _estoqueController.text = produto.estoque.toString();
          _precoCustoController.text = produto.precoCusto.toString();

          if (produto.id_categoria != null && _categorias.isNotEmpty) {
            _selectedCategory = _categorias.firstWhere(
              (c) => c.id == produto.id_categoria,
              orElse: () => _categorias.first,
            );
          }
          if (produto.id_unidade != null && _unidades.isNotEmpty) {
            _selectedUnit = _unidades.firstWhere(
              (u) => u.id == produto.id_unidade,
              orElse: () => _unidades.first,
            );
          }

          imageUrl = produto.image_url ?? '';
          _ativo = produto.ativo ?? true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produto não encontrado!',
                style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erro ao carregar produto: $e', style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    final file = File(pickedFile.path);
    try {
      final url = await produtocontroller.uploadImage(file);
      if (!mounted) return;
      setState(() {
        imageUrl = url;
        _isUploadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erro ao enviar imagem: $e', style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  void _showCategoriaPopup() {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            'Nova Categoria',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: _inputDecoration(ctx, 'Nome da Categoria'),
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: _gapMd),
              TextField(
                controller: descricaoController,
                decoration: _inputDecoration(ctx, 'Descrição'),
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: cs.onSurface)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: const Text('Salvar'),
              onPressed: () async {
                if (nomeController.text.isEmpty) return;
                try {
                  await categoriaController.inserirCategoria({
                    'nome': nomeController.text,
                    'descricao': descricaoController.text
                  });
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  await _carregarListasCategoria();
                  if (!mounted) return;
                  setState(() {
                    if (_categorias.isNotEmpty) {
                      _selectedCategory = _categorias.last;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categoria criada com sucesso!',
                          style: TextStyle(color: cs.onPrimary)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao criar categoria: $e',
                          style: TextStyle(color: cs.onError)),
                      backgroundColor: cs.error,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnidadePopup() {
    final nomeController = TextEditingController();
    final siglaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            'Nova Unidade de Medida',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: _inputDecoration(ctx, 'Nome da Unidade'),
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: _gapMd),
              TextField(
                controller: siglaController,
                decoration: _inputDecoration(ctx, 'Sigla'),
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: cs.onSurface)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: const Text('Salvar'),
              onPressed: () async {
                if (nomeController.text.isEmpty ||
                    siglaController.text.isEmpty) return;
                try {
                  await unidadeController.inserirUnidade({
                    'nome': nomeController.text,
                    'sigla': siglaController.text
                  });
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  await _carregarListasUnidade();
                  if (!mounted) return;
                  setState(() {
                    if (_unidades.isNotEmpty) {
                      _selectedUnit = _unidades.last;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unidade criada com sucesso!',
                          style: TextStyle(color: cs.onPrimary)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao criar unidade: $e',
                          style: TextStyle(color: cs.onError)),
                      backgroundColor: cs.error,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _codigoController.dispose();
    _precoVendaController.dispose();
    _estoqueController.dispose();
    _validadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          _isEdicao ? 'Editar Produto' : 'Cadastrar Produto',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(false);
            } else {
              Navigator.of(context).pushReplacementNamed('/listProdutos');
            }
          },
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.7),
          labelStyle:
              tt.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: tt.labelLarge?.copyWith(fontSize: 12),
          tabs: const [
            Tab(text: 'Dados Cadastrais'),
            Tab(text: 'Dados Fiscais'),
            Tab(text: 'Composição'),
            Tab(text: 'Opcionais'),
            Tab(text: 'Características'),
          ],
        ),
      ),

      // ⬇️ Barra de navegação inferior oficial do app
      bottomNavigationBar: AppNavBar(
        currentRoute: ModalRoute.of(context)?.settings.name,
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDadosCadastrais(),
                _buildEmptyTab('Dados Fiscais'),
                _buildEmptyTab('Composição'),
                _buildEmptyTab('Opcionais'),
                _buildEmptyTab('Características'),
              ],
            ),
    );
  }

  Widget _buildDadosCadastrais() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nome do Produto'),
          _buildTextField(_nomeController, 'Digite o nome do produto'),
          const SizedBox(height: _gapMd),

          _buildLabel('Código do Produto'),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _codigoController,
                  'Digite o código ou escaneie',
                ),
              ),
              const SizedBox(width: _gapSm),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: cs.onSurface),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: _gapMd),

          _buildLabel('Categoria'),
          Row(
            children: [
              Expanded(child: _buildCategoriaDropdown()),
              const SizedBox(width: _gapSm),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: cs.onSurface),
                  onPressed: _showCategoriaPopup,
                ),
              ),
            ],
          ),
          const SizedBox(height: _gapMd),

          _buildLabel('Unidade'),
          Row(
            children: [
              Expanded(child: _buildUnidadeDropdown()),
              const SizedBox(width: _gapSm),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: cs.onSurface),
                  onPressed: _showUnidadePopup,
                ),
              ),
            ],
          ),
          const SizedBox(height: _gapMd),

          _buildLabel('Preço de Custo'),
          _buildTextField(
            _precoCustoController,
            'R\$ 0,00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalInputFormatters,
          ),
          const SizedBox(height: _gapMd),

          _buildLabel('Preço de Venda'),
          _buildTextField(
            _precoVendaController,
            'R\$ 0,00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalInputFormatters,
          ),
          const SizedBox(height: _gapMd),

          _buildLabel(_isEdicao ? 'Estoque Atual' : 'Estoque Inicial'),
          _buildTextField(
            _estoqueController,
            '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalInputFormatters,
            readOnly: _isEdicao,
          ),
          const SizedBox(height: _gapMd),

          Row(
            children: [
              Checkbox(
                value: _ativo,
                onChanged: (value) => setState(() => _ativo = value ?? true),
                activeColor: cs.primary,
                checkColor: cs.onPrimary,
              ),
              Text(
                'Produto Ativo',
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: _gapMd),

          _buildLabel('Data de Validade (opcional)'),
          _buildTextField(
            _validadeController,
            'DD/MM/AAAA',
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                builder: (ctx, child) {
                  return Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: Theme.of(ctx).colorScheme,
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                _validadeController.text =
                    "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
              }
            },
          ),
          const SizedBox(height: 24),

          // Imagem
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Stack(
              children: [
                if (_isUploadingImage)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else if ((imageUrl ?? '').isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                if (!_isUploadingImage)
                  GestureDetector(
                    onTap: () async {
                      try {
                        await pickAndUploadImage();
                      } catch (e) {
                        if (!mounted) return;
                        final cs = Theme.of(context).colorScheme;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao enviar imagem: $e',
                                style: TextStyle(color: cs.onError)),
                            backgroundColor: cs.error,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: (imageUrl ?? '').isNotEmpty
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: (imageUrl ?? '').isNotEmpty
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 24),
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                  size: 30,
                                ),
                                const SizedBox(height: _gapSm),
                                Text(
                                  'Adicionar Imagem',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Botão Cadastrar/Atualizar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _onSalvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              child: Text(_isEdicao ? 'Atualizar Produto' : 'Cadastrar Produto'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
      filled: true,
      fillColor: cs.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildCategoriaDropdown() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Categoria>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: cs.surface,
          style: TextStyle(color: cs.onSurface),
          icon: Icon(Icons.arrow_drop_down, color: cs.onSurface.withValues(alpha: 0.7)),
          hint: Text('Selecione a categoria',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
          items: _categorias
              .map((c) => DropdownMenuItem<Categoria>(
                    value: c,
                    child: Text(c.nome, style: TextStyle(color: cs.onSurface)),
                  ))
              .toList(),
          onChanged: (Categoria? categoria) {
            setState(() => _selectedCategory = categoria);
          },
        ),
      ),
    );
  }

  Widget _buildUnidadeDropdown() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Unidade>(
          value: _selectedUnit,
          isExpanded: true,
          dropdownColor: cs.surface,
          style: TextStyle(color: cs.onSurface),
          icon: Icon(Icons.arrow_drop_down, color: cs.onSurface.withValues(alpha: 0.7)),
          hint: Text('Selecione a unidade',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
          items: _unidades
              .map((u) => DropdownMenuItem<Unidade>(
                    value: u,
                    child: Text('${u.nome} (${u.sigla})',
                        style: TextStyle(color: cs.onSurface)),
                  ))
              .toList(),
          onChanged: (Unidade? unidade) {
            setState(() => _selectedUnit = unidade);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String tabName) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: cs.onSurface.withValues(alpha: 0.6), size: 60),
          const SizedBox(height: _gapMd),
          Text(tabName,
              style: tt.titleMedium
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold)),
          const SizedBox(height: _gapSm),
          Text(
            'Esta seção ainda está em desenvolvimento',
            style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: _gapSm),
      child: Text(
        text,
        style: tt.bodyMedium
            ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onTap: onTap,
      readOnly: onTap != null || readOnly,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _onSalvar() async {
    final cs = Theme.of(context).colorScheme;

    try {
      // validações de campos obrigatórios
      if (_nomeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nome do produto é obrigatório!',
                style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        return;
      }
      if (_codigoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código do produto é obrigatório!',
                style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selecione uma categoria para o produto!',
                style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        return;
      }
      if (_selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selecione uma unidade de medida para o produto!',
                style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        return;
      }

      // validações numéricas
      final precoVenda = _toDouble(_precoVendaController.text);
      final precoCusto = _toDouble(_precoCustoController.text);
      final estoque = _toDouble(_estoqueController.text);

      if (precoVenda < 0 || precoCusto < 0 || estoque < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Valores não podem ser negativos.',
                style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        return;
      }

      // monta payload
      final dadosProduto = {
        'descricao': _nomeController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'preco_venda': precoVenda,
        'id_categoria': _selectedCategory?.id,
        'id_unidade': _selectedUnit?.id,
        'preco_custo': precoCusto,
        'validade': _validadeController.text.trim(),
        'image_url': imageUrl ?? '',
        'ativo': _ativo,
      };

      final dadosQuantidadeEstoque = {'quantidade': estoque};

      final dadosMovimentacaoEstoque = {
        'quantidade': estoque,
        'tipo_movimento': 'Entrada'
      };

      if (_isEdicao) {
        dadosQuantidadeEstoque['id_produto_empresa'] = _produtoEdicao!.id.toDouble();
        dadosMovimentacaoEstoque['id_produto_empresa'] = _produtoEdicao!.id.toDouble();
        dadosProduto['produto_id_public'] = _produtoEdicao!.produtoIdPublic;
        await produtocontroller.atualizarProduto(dadosProduto);
      } else {
        final idProduto = await produtocontroller.inserirProduto(dadosProduto);
        dadosQuantidadeEstoque['id_produto_empresa'] = idProduto.toDouble();
        dadosMovimentacaoEstoque['id_produto_empresa'] = idProduto.toDouble();
        await estoqueController.inserirQuantidadeEstoque(dadosQuantidadeEstoque);
        if (estoque != 0.0) {
          await estoqueController.inserirMovimentacaoEstoque(dadosMovimentacaoEstoque);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdicao
                ? 'Produto atualizado com sucesso!'
                : 'Produto cadastrado com sucesso!',
            style: TextStyle(color: cs.onPrimary),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e', style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
    }
  }
}
