import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
  final _complementoCtrl = TextEditingController();
  final _pontoReferenciaCtrl = TextEditingController();

  String _tipoContribuinte = 'N';

  final _cnpjMask = MaskTextInputFormatter(mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});

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
    _complementoCtrl.dispose();
    _pontoReferenciaCtrl.dispose();
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
          content: Text('Erro ao carregar dados: $e', style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFornecedorData() async {
    try {
      final fornecedor = await _controller.buscarFornecedorPorId(widget.fornecedorId!);
      if (fornecedor == null) throw Exception('Fornecedor não encontrado');

      _razaoSocialCtrl.text = fornecedor.razaoSocial ?? '';
      _nomeFantasiaCtrl.text = fornecedor.nomeFantasia ?? '';
      _cnpjCtrl.text = _cnpjMask.maskText(fornecedor.cnpj ?? '');
      _ieCtrl.text = fornecedor.ie ?? '';
      _telefoneCtrl.text = _telefoneMask.maskText(fornecedor.telefone?.numero ?? '');
      _emailCtrl.text = fornecedor.email ?? '';
      _cepCtrl.text = _cepMask.maskText(fornecedor.endereco?.cep ?? '');
      _logradouroCtrl.text = fornecedor.endereco?.logradouro ?? '';
      _numeroCtrl.text = fornecedor.endereco?.numero ?? '';
      _bairroCtrl.text = fornecedor.endereco?.bairro ?? '';
      _cidadeCtrl.text = fornecedor.endereco?.cidade ?? '';
      _ufCtrl.text = fornecedor.endereco?.uf ?? '';
      _complementoCtrl.text = fornecedor.endereco?.complemento ?? '';
      _pontoReferenciaCtrl.text = fornecedor.endereco?.pontoReferencia ?? '';
      _tipoContribuinte = fornecedor.situacao_ie ?? 'N';

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar fornecedor: $e', style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação obrigatória extra
    if (_cnpjCtrl.text.trim().isEmpty || _razaoSocialCtrl.text.trim().isEmpty || _nomeFantasiaCtrl.text.trim().isEmpty) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha CNPJ, Razão Social e Nome Fantasia!', style: TextStyle(color: cs.onError)),
          backgroundColor: cs.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fornecedorMap = {
        "id": widget.fornecedorId,
        "nome_razao": _razaoSocialCtrl.text,
        "email": _emailCtrl.text,
        "cpf_cnpj": _cnpjCtrl.text,
        "rg_ie": _ieCtrl.text,
        "tipo_pessoa": "J", // ou "F" conforme sua lógica
        "situacao_ie": _tipoContribuinte, // <-- aqui vai N, I ou C
        "fornecedor": true,
        "nome_popular": _nomeFantasiaCtrl.text,
        "cep": _cepMask.unmaskText(_cepCtrl.text),
        "logradouro": _logradouroCtrl.text,
        "numero": _numeroCtrl.text,
        "complemento": _complementoCtrl.text,
        "ponto_referencia": _pontoReferenciaCtrl.text,
        "cidade": _cidadeCtrl.text,
        "estado": _ufCtrl.text,
        "bairro": _bairroCtrl.text,
        "telefone": _telefoneMask.unmaskText(_telefoneCtrl.text),
      };

      if (_isEdicao) {
        await _controller.atualizarFornecedor(fornecedorMap);
        if (!mounted) return;
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fornecedor atualizado com sucesso!', style: TextStyle(color: cs.onPrimary)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      // Cadastro novo fornecedor
      try {
        // Tenta validar existência do fornecedor
        await _controller.validarExistenciaDoFornecedor(_cnpjCtrl.text);

        // Se não lançar exceção, o fornecedor já está cadastrado e vinculado
        if (!mounted) return;
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fornecedor já está na nossa base de dados e vinculado à sua empresa.', style: TextStyle(color: cs.onError)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isLoading = false);
        return;
      } on FornecedorCotrollerException catch (e) {
        // Agora esse bloco será chamado corretamente!
        if (!mounted) return;
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
        setState(() => _isLoading = false);
        return;
      } catch (_) {
        // Se lançar qualquer outra exceção, significa que o fornecedor não existe e pode ser cadastrado
        // Continua para cadastrarFornecedor
      }

      // Se chegou aqui, pode cadastrar o fornecedor normalmente
      await _controller.cadastrarFornecedor(fornecedorMap);

      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fornecedor cadastrado com sucesso!', style: TextStyle(color: cs.onPrimary)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e', style: TextStyle(color: cs.onError)),
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
          style: tt.titleMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),
      body: _isLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(cs.primary))) : _buildForm(),
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
            _buildTextField(_razaoSocialCtrl, 'Digite a razão social do fornecedor', validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null),
            const SizedBox(height: _gapMd),

            _buildLabel('Nome Fantasia'),
            _buildTextField(_nomeFantasiaCtrl, 'Digite o nome fantasia'),
            const SizedBox(height: _gapMd),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CNPJ'),
                      _buildTextField(
                        _cnpjCtrl,
                        'Digite o CNPJ',
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly, // Só permite números
                          LengthLimitingTextInputFormatter(14), // Limita a 14 dígitos do CNPJ
                        ],
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: _gapSm),
                Expanded(
                  flex: 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Inscrição Estadual'), _buildTextField(_ieCtrl, 'Digite a inscrição estadual')]),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Telefone'),
            _buildTextField(_telefoneCtrl, 'Digite o telefone', keyboardType: TextInputType.number, formatters: [_telefoneMask]),
            const SizedBox(height: _gapMd),

            _buildLabel('E-mail'),
            _buildTextField(_emailCtrl, 'Digite o e-mail'),
            const SizedBox(height: 24),

            _buildLabel('CEP'),
            _buildTextField(_cepCtrl, 'Digite o CEP', keyboardType: TextInputType.number, formatters: [_cepMask]),
            const SizedBox(height: _gapMd),

            _buildLabel('Logradouro'),
            _buildTextField(_logradouroCtrl, 'Digite o logradouro'),
            const SizedBox(height: _gapMd),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Número'), _buildTextField(_numeroCtrl, 'Nº')]),
                ),
                const SizedBox(width: _gapSm),
                Expanded(
                  flex: 3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Bairro'), _buildTextField(_bairroCtrl, 'Digite o bairro')]),
                ),
              ],
            ),
            const SizedBox(height: _gapMd),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Cidade'), _buildTextField(_cidadeCtrl, 'Digite a cidade')]),
                ),
                const SizedBox(width: _gapSm),
                Expanded(
                  flex: 1,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('UF'), _buildTextField(_ufCtrl, 'UF')]),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Complemento'),
            TextFormField(
              controller: _complementoCtrl,
              decoration: InputDecoration(
                hintText: 'Complemento',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: _gapMd),

            _buildLabel('Ponto de Referência'),
            TextFormField(
              controller: _pontoReferenciaCtrl,
              decoration: InputDecoration(
                hintText: 'Ponto de referência',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: _gapMd),

            _buildLabel('Tipo de Contribuinte'),
            DropdownButtonFormField<String>(
              value: _tipoContribuinte,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: [
                DropdownMenuItem(value: 'N', child: Text('Não Contribuinte')),
                DropdownMenuItem(value: 'I', child: Text('Isento')),
                DropdownMenuItem(value: 'C', child: Text('Contribuinte')),
              ],
              onChanged: (valor) {
                setState(() {
                  _tipoContribuinte = valor ?? 'N';
                });
              },
            ),
            const SizedBox(height: _gapMd),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(_isEdicao ? 'Atualizar Fornecedor' : 'Cadastrar Fornecedor'),
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
        style: tt.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {String? Function(String?)? validator, TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
