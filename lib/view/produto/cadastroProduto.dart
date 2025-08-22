// cadastroProduto.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedeai/controller/estoqueController.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/controller/categoriaController.dart';
import 'package:pedeai/controller/unidadeController.dart';
import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/model/unidade.dart';

class CadastroProdutoPage extends StatefulWidget {
  final int? produtoId;

  const CadastroProdutoPage({Key? key, this.produtoId}) : super(key: key);

  @override
  _CadastroProdutoPageState createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers para os campos
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _codigoController = TextEditingController();
  TextEditingController _precoVendaController = TextEditingController();
  TextEditingController _precoCustoController = TextEditingController();
  TextEditingController _estoqueController = TextEditingController();
  TextEditingController _validadeController = TextEditingController();

  Produtocontroller produtocontroller = Produtocontroller();
  Categoriacontroller categoriaController = Categoriacontroller();
  Unidadecontroller unidadeController = Unidadecontroller();
  Estoquecontroller estoqueController = Estoquecontroller();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _isEdicao = widget.produtoId != null;

    _carregarListas();

    if (_isEdicao) {
      _carregarDadosProduto();
    }
  }

  Future<void> _carregarListas() async {
    try {
      final categorias = await categoriaController.listarCategoria();
      final unidades = await unidadeController.listarUnidade();

      setState(() {
        _categorias.clear();
        _unidades.clear();
        _categorias = categorias;
        _unidades = unidades;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar listas: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _carregarDadosProduto() async {
    if (widget.produtoId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Produto? produto = await produtocontroller.buscarProdutoPorId(widget.produtoId!);

      if (produto != null) {
        if (_categorias.isEmpty || _unidades.isEmpty) {
          await _carregarListas();
        }

        setState(() {
          _produtoEdicao = produto;
          _nomeController.text = produto.descricao;
          _codigoController.text = produto.codigo;
          _precoVendaController.text = produto.preco.toString();
          _estoqueController.text = produto.estoque.toString();

          // Buscar e definir categoria selecionada
          if (produto.id_categoria != null) {
            _selectedCategory = _categorias.firstWhere((categoria) => categoria.id == produto.id_categoria, orElse: () => _categorias.first);
          }

          // Buscar e definir unidade selecionada
          if (produto.id_unidade != null) {
            _selectedUnit = _unidades.firstWhere((unidade) => unidade.id == produto.id_unidade, orElse: () => _unidades.first);
          }

          imageUrl = produto.image_url ?? '';
          _ativo = produto.ativo ?? true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto não encontrado!'), backgroundColor: Colors.red));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar produto: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    final file = File(pickedFile.path);
    try {
      final url = await produtocontroller.uploadImage(file);
      setState(() {
        imageUrl = url;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar imagem: $e'), backgroundColor: Colors.red));
    }
  }

  // Popup para cadastrar categoria
  void _showCategoriaPopup() {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D2419),
          title: Text(
            'Nova Categoria',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Categoria',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF4A3429),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF4A3429),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: Colors.white),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Salvar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (nomeController.text.isNotEmpty) {
                  try {
                    await categoriaController.inserirCategoria({'nome': nomeController.text, 'descricao': descricaoController.text});

                    Navigator.of(context).pop();
                    await _carregarListas(); // Recarregar a lista
                    setState(() {
                      // Seleciona a categoria recém criada (exemplo: última da lista)
                      if (_categorias.isNotEmpty) {
                        _selectedCategory = _categorias.last;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Categoria criada com sucesso!'), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar categoria: $e'), backgroundColor: Colors.red));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Popup para cadastrar unidade
  void _showUnidadePopup() {
    final nomeController = TextEditingController();
    final siglaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D2419),
          title: Text(
            'Nova Unidade de Medida',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Unidade',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF4A3429),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: siglaController,
                decoration: InputDecoration(
                  labelText: 'Sigla',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF4A3429),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Salvar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (nomeController.text.isNotEmpty && siglaController.text.isNotEmpty) {
                  try {
                    await unidadeController.inserirUnidade({'nome': nomeController.text, 'sigla': siglaController.text});

                    Navigator.of(context).pop();
                    await _carregarListas(); // Recarregar a lista
                    setState(() {
                      // Seleciona a unidade recém criada (exemplo: última da lista)
                      if (_unidades.isNotEmpty) {
                        _selectedUnit = _unidades.last;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unidade criada com sucesso!'), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar unidade: $e'), backgroundColor: Colors.red));
                  }
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
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        title: Text(
          _isEdicao ? 'Editar Produto' : 'Cadastrar Produto',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          tabs: [
            Tab(text: 'Dados Cadastrais'),
            Tab(text: 'Dados Fiscais'),
            Tab(text: 'Composição'),
            Tab(text: 'Opcionais'),
            Tab(text: 'Características'),
          ],
        ),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange))) : TabBarView(controller: _tabController, children: [_buildDadosCadastrais(), _buildEmptyTab('Dados Fiscais'), _buildEmptyTab('Composição'), _buildEmptyTab('Opcionais'), _buildEmptyTab('Características')]),
    );
  }

  Widget _buildDadosCadastrais() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Produto
          _buildLabel('Nome do Produto'),
          _buildTextField(_nomeController, 'Digite o nome do produto'),
          SizedBox(height: 16),

          // Código do Produto
          _buildLabel('Código do Produto'),
          Row(
            children: [
              Expanded(child: _buildTextField(_codigoController, 'Digite o código ou escaneie')),
              SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Categoria
          _buildLabel('Categoria'),
          Row(
            children: [
              Expanded(child: _buildCategoriaDropdown()),
              SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _showCategoriaPopup,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Unidade
          _buildLabel('Unidade'),
          Row(
            children: [
              Expanded(child: _buildUnidadeDropdown()),
              SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _showUnidadePopup,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Preço de Custo
          _buildLabel('Preço de Custo'),
          _buildTextField(_precoCustoController, 'R\$ 0,00', keyboardType: TextInputType.number),
          SizedBox(height: 16),

          // Preço de Venda
          _buildLabel('Preço de Venda'),
          _buildTextField(_precoVendaController, 'R\$ 0,00', keyboardType: TextInputType.number),
          SizedBox(height: 16),

          // Estoque Inicial
          _buildLabel(_isEdicao ? 'Estoque Atual' : 'Estoque Inicial'),
          _buildTextField(_estoqueController, '0', keyboardType: TextInputType.number, readOnly: _isEdicao),
          SizedBox(height: 16),

          // Status Ativo
          Row(
            children: [
              Checkbox(
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value ?? true;
                  });
                },
                activeColor: Colors.orange,
                checkColor: Colors.white,
              ),
              Text(
                'Produto Ativo',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Data de Validade
          _buildLabel('Data de Validade (opcional)'),
          _buildTextField(
            _validadeController,
            'DD/MM/AAAA',
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(), // Só permite datas atuais ou futuras
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: Colors.orange, onPrimary: Colors.white, onSurface: Colors.black),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                _validadeController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
              }
            },
          ),
          SizedBox(height: 24),

          // Adicionar Imagem
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Stack(
              children: [
                if (_isUploadingImage)
                  Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
                else if (imageUrl != null && imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                    ),
                  ),
                if (!_isUploadingImage)
                  GestureDetector(
                    onTap: () async {
                      try {
                        await pickAndUploadImage();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar imagem: $e'), backgroundColor: Colors.red));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: imageUrl != null && imageUrl!.isNotEmpty ? Colors.transparent : Color(0xFF4A3429),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30, style: BorderStyle.solid, width: 1),
                      ),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                  child: Icon(Icons.edit, color: Colors.white, size: 24),
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.white54, size: 30),
                                SizedBox(height: 8),
                                Text('Adicionar Imagem', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Botão Cadastrar/Atualizar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  // Validações básicas
                  if (_nomeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nome do produto é obrigatório!'), backgroundColor: Colors.red));
                    return;
                  }

                  if (_codigoController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Código do produto é obrigatório!'), backgroundColor: Colors.red));
                    return;
                  }

                  if (_selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione uma categoria para o produto!'), backgroundColor: Colors.red));
                    return;
                  }

                  if (_selectedUnit == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione uma unidade de medida para o produto!'), backgroundColor: Colors.red));
                    return;
                  }

                  Map<String, dynamic> dadosProduto = {
                    'descricao': _nomeController.text.trim(),
                    'codigo': _codigoController.text.trim(),
                    'preco_venda': double.tryParse(_precoVendaController.text) ?? 0.0,
                    'id_categoria': _selectedCategory?.id,
                    'id_unidade': _selectedUnit?.id,
                    'preco_custo': double.tryParse(_precoCustoController.text) ?? 0.0,
                    'validade': _validadeController.text.trim(),
                    'image_url': imageUrl ?? '',
                    'ativo': _ativo,
                  };

                  Map<String, dynamic> dadosQuantidadeEstoque = {'quantidade': double.tryParse(_estoqueController.text) ?? 0};

                  Map<String, dynamic> dadosMovimentacaoEstoque = {'quantidade': double.tryParse(_estoqueController.text) ?? 0, 'tipo_movimento': 'Entrada'};

                  if (_isEdicao) {
                    dadosQuantidadeEstoque['id_produto_empresa'] = _produtoEdicao!.id;
                    dadosMovimentacaoEstoque['id_produto_empresa'] = _produtoEdicao!.id;
                    dadosProduto['produto_id_public'] = _produtoEdicao!.produtoIdPublic;
                    await produtocontroller.atualizarProduto(dadosProduto);
                  } else {
                    int idProduto = await produtocontroller.inserirProduto(dadosProduto);
                    dadosQuantidadeEstoque['id_produto_empresa'] = idProduto;
                    dadosMovimentacaoEstoque['id_produto_empresa'] = idProduto;
                    await estoqueController.inserirQuantidadeEstoque(dadosQuantidadeEstoque);
                    await estoqueController.inserirMovimentacaoEstoque(dadosMovimentacaoEstoque);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdicao ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!'), backgroundColor: Colors.green));

                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _isEdicao ? 'Atualizar Produto' : 'Cadastrar Produto',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Categoria>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: Color(0xFF4A3429),
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
          hint: Text('Selecione a categoria', style: TextStyle(color: Colors.white54)),
          items: _categorias.map((Categoria categoria) {
            return DropdownMenuItem<Categoria>(
              value: categoria,
              child: Text(categoria.nome, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (Categoria? categoria) {
            setState(() {
              _selectedCategory = categoria;
            });
          },
        ),
      ),
    );
  }

  Widget _buildUnidadeDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Unidade>(
          value: _selectedUnit,
          isExpanded: true,
          dropdownColor: Color(0xFF4A3429),
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
          hint: Text('Selecione a unidade', style: TextStyle(color: Colors.white54)),
          items: _unidades.map((Unidade unidade) {
            return DropdownMenuItem<Unidade>(
              value: unidade,
              child: Text('${unidade.nome} (${unidade.sigla})', style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (Unidade? unidade) {
            setState(() {
              _selectedUnit = unidade;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Colors.white54, size: 60),
          SizedBox(height: 16),
          Text(
            '$tabName',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Esta seção ainda está em desenvolvimento', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType? keyboardType, VoidCallback? onTap, bool readOnly = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: onTap != null || readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Color(0xFF4A3429),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
