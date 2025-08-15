// product_registration_page.dart
import 'package:flutter/material.dart';
import 'package:pedeai/controller/produtoController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/produto.dart';

class CadastroProdutoPage extends StatefulWidget {
  final int? produtoId; // Null para cadastro, preenchido para edição
  
  const CadastroProdutoPage({Key? key, this.produtoId}) : super(key: key);

  @override
  _CadastroProdutoPageState createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers para os campos
  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _validityController = TextEditingController();
  Produtocontroller produtocontroller = Produtocontroller();

  String _selectedCategory = 'Selecione a categoria';
  String _selectedUnit = 'Selecione a unidade';
  
  bool _isLoading = false;
  bool _isEdicao = false;
  Produto? _produtoEdicao;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _isEdicao = widget.produtoId != null;
    
    if (_isEdicao) {
      _carregarDadosProduto();
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
        setState(() {
          _produtoEdicao = produto;
          _nameController.text = produto.descricao;
          _codeController.text = produto.codigo;
          _priceController.text = produto.preco.toString();
          _stockController.text = produto.estoque.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produto não encontrado!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar produto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _validityController.dispose();
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
      body: _isLoading 
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : TabBarView(
              controller: _tabController, 
              children: [
                _buildDadosCadastrais(), 
                _buildEmptyTab('Dados Fiscais'), 
                _buildEmptyTab('Composição'), 
                _buildEmptyTab('Opcionais'), 
                _buildEmptyTab('Características')
              ]
            ),
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
          _buildTextField(_nameController, 'Digite o nome do produto'),
          SizedBox(height: 16),

          // Código do Produto
          _buildLabel('Código do Produto'),
          Row(
            children: [
              Expanded(child: _buildTextField(_codeController, 'Digite o código ou escaneie')),
              SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  // o ideal é buscar em alguma api os dados do produto ao le o codigo de barras
                  icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Categoria
          _buildLabel('Categoria'),
          _buildDropdown(_selectedCategory, ['Selecione a categoria', 'Sanduíche', 'Pizza', 'Bebida', 'Sobremesa'], (value) {
            setState(() {
              _selectedCategory = value!;
            });
          }),
          SizedBox(height: 16),

          // Unidade
          _buildLabel('Unidade'),
          _buildDropdown(_selectedUnit, ['Selecione a unidade', 'Unidade', 'Kg', 'Litro', 'Metro'], (value) {
            setState(() {
              _selectedUnit = value!;
            });
          }),
          SizedBox(height: 16),

          // Preço de Venda
          _buildLabel('Preço de Venda'),
          _buildTextField(_priceController, 'R\$ 0,00', keyboardType: TextInputType.number),
          SizedBox(height: 16),

          // Estoque Inicial
          _buildLabel(_isEdicao ? 'Estoque Atual' : 'Estoque Inicial'),
          _buildTextField(_stockController, '0', keyboardType: TextInputType.number),
          SizedBox(height: 16),

          // Data de Validade
          _buildLabel('Data de Validade (opcional)'),
          _buildTextField(
            _validityController,
            'DD/MM/AAAA',
            onTap: () {
              // Implementar date picker
            },
          ),
          SizedBox(height: 24),

          // Adicionar Imagem
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFF4A3429),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white30, style: BorderStyle.solid, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, color: Colors.white54, size: 30),
                SizedBox(height: 8),
                Text('Adicionar Imagem', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                  if (_isEdicao) {
                    // Atualizar produto existente
                    await produtocontroller.atualizarProduto({
                      'produto_id_public': _produtoEdicao!.produtoIdPublic,
                      'descricao': _nameController.text,
                      'codigo': _codeController.text,
                      'preco': double.tryParse(_priceController.text) ?? 0.0,
                      'estoque': double.tryParse(_stockController.text) ?? 0
                    });
                  } else {
                    // Inserir novo produto
                    await produtocontroller.inserirProdutoComPreco({
                      'schema_empresa': 'georgiadoceria', // Idealmente pegar da empresa atual
                      'descricao': _nameController.text,
                      'codigo': _codeController.text,
                      'preco': double.tryParse(_priceController.text) ?? 0.0,
                      'estoque': double.tryParse(_stockController.text) ?? 0
                    });
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isEdicao ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  Navigator.pop(context, true); // Retorna true para indicar que houve alteração
                  
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType? keyboardType, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: onTap != null,
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

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Color(0xFF4A3429),
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}