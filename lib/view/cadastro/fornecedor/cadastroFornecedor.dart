import 'package:flutter/material.dart';
import 'package:pedeai/controller/fornecedorController.dart';
import 'package:pedeai/model/fornecedor.dart';
import 'package:pedeai/app_nav_bar.dart';

class CadastroFornecedorPage extends StatefulWidget {
  final int? fornecedorId;
  const CadastroFornecedorPage({super.key, this.fornecedorId});

  @override
  State<CadastroFornecedorPage> createState() => _CadastroFornecedorPageState();
}

class _CadastroFornecedorPageState extends State<CadastroFornecedorPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = FornecedorController();

  // Controllers de formulário
  final _razaoSocialCtrl = TextEditingController();
  final _nomeFantasiaCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _ieCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _logradouroCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _ufCtrl = TextEditingController();

  bool get _isEdicao => widget.fornecedorId != null;
  bool _isLoading = true;

  // Spacing constants
  static const double _gapSm = 8;
  static const double _gapMd = 16;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _razaoSocialCtrl.dispose();
    _nomeFantasiaCtrl.dispose();
    _cnpjCtrl.dispose();
    _ieCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _cepCtrl.dispose();
    _logradouroCtrl.dispose();
    _numeroCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _ufCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (_isEdicao) {
        await _loadFornecedorData();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar dados: $e',
            style: TextStyle(color: cs.onError),
          ),
          backgroundColor: cs.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFornecedorData() async {
    try {
      final fornecedor = (await _controller.listarFornecedores()).firstWhere(
        (f) => f.id == widget.fornecedorId,
      );

      _razaoSocialCtrl.text = fornecedor.razaoSocial;
      _nomeFantasiaCtrl.text = fornecedor.nomeFantasia ?? '';
      _cnpjCtrl.text = fornecedor.cnpj ?? '';
      _ieCtrl.text = fornecedor.ie ?? '';
      _telefoneCtrl.text = fornecedor.telefone ?? '';
      _emailCtrl.text = fornecedor.email ?? '';
      _cepCtrl.text = fornecedor.cep ?? '';
      _logradouroCtrl.text = fornecedor.logradouro ?? '';
      _numeroCtrl.text = fornecedor.numero ?? '';
      _bairroCtrl.text = fornecedor.bairro ?? '';
      _cidadeCtrl.text = fornecedor.cidade ?? '';
      _ufCtrl.text = fornecedor.uf ?? '';

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar fornecedor: $e',
            style: TextStyle(color: cs.onError),
          ),
          backgroundColor: cs.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fornecedor = Fornecedor(
        id: widget.fornecedorId,
        razaoSocial: _razaoSocialCtrl.text.trim(),
        nomeFantasia: _nomeFantasiaCtrl.text.trim(),
        cnpj: _cnpjCtrl.text.trim(),
        ie: _ieCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        cep: _cepCtrl.text.trim(),
        logradouro: _logradouroCtrl.text.trim(),
        numero: _numeroCtrl.text.trim(),
        bairro: _bairroCtrl.text.trim(),
        cidade: _cidadeCtrl.text.trim(),
        uf: _ufCtrl.text.trim(),
      );

      if (_isEdicao) {
        await _controller.atualizarFornecedor(fornecedor);
      } else {
        await _controller.cadastrarFornecedor(fornecedor);
      }

      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdicao
                ? 'Fornecedor atualizado com sucesso!'
                : 'Fornecedor cadastrado com sucesso!',
            style: TextStyle(color: cs.onPrimary),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar: $e',
            style: TextStyle(color: cs.onError),
          ),
          backgroundColor: cs.error,
        ),
      );
      setState(() => _isLoading = false);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(false);
            } else {
              Navigator.of(context).pushReplacementNamed('/listFornecedores');
            }
          },
        ),
        title: Text(
          _isEdicao ? 'Editar Fornecedor' : 'Cadastrar Fornecedor',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_gapMd),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção Dados Gerais
            _buildLabel('Razão Social'),
            _buildTextField(
              _razaoSocialCtrl,
              'Digite a razão social do fornecedor',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: _gapMd),

            _buildLabel('Nome Fantasia'),
            _buildTextField(_nomeFantasiaCtrl, 'Digite o nome fantasia'),
            const SizedBox(height: _gapMd),

            _buildLabel('CNPJ'),
            _buildTextField(_cnpjCtrl, 'Digite o CNPJ'),
            const SizedBox(height: _gapMd),

            _buildLabel('Inscrição Estadual'),
            _buildTextField(_ieCtrl, 'Digite a inscrição estadual'),
            const SizedBox(height: 24),

            _buildLabel('Telefone'),
            _buildTextField(_telefoneCtrl, 'Digite o telefone'),
            const SizedBox(height: _gapMd),

            _buildLabel('E-mail'),
            _buildTextField(_emailCtrl, 'Digite o e-mail'),
            const SizedBox(height: 24),

            _buildLabel('CEP'),
            _buildTextField(_cepCtrl, 'Digite o CEP'),
            const SizedBox(height: _gapMd),

            _buildLabel('Logradouro'),
            _buildTextField(_logradouroCtrl, 'Digite o logradouro'),
            const SizedBox(height: _gapMd),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Número'),
                      _buildTextField(_numeroCtrl, 'Nº'),
                    ],
                  ),
                ),
                const SizedBox(width: _gapSm),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Bairro'),
                      _buildTextField(_bairroCtrl, 'Digite o bairro'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: _gapMd),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Cidade'),
                      _buildTextField(_cidadeCtrl, 'Digite a cidade'),
                    ],
                  ),
                ),
                const SizedBox(width: _gapSm),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('UF'),
                      _buildTextField(_ufCtrl, 'UF'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(
                  _isEdicao ? 'Atualizar Fornecedor' : 'Cadastrar Fornecedor',
                ),
              ),
            ),
          ],
        ),
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
        style: tt.bodyMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
