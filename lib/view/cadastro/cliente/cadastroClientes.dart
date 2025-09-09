import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pedeai/controller/clienteController.dart';
import 'package:pedeai/model/cliente.dart';
import 'package:pedeai/app_nav_bar.dart';

class CadastroClientePage extends StatefulWidget {
  final int? clienteId;
  const CadastroClientePage({super.key, this.clienteId});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ClienteController();

  // Controllers de formulário
  final _razaoSocialCtrl = TextEditingController();
  final _nomeFantasiaCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _ieCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dataNascimentoCtrl = TextEditingController();
  final _codFidelidadeCtrl = TextEditingController();
  final _sexoCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _logradouroCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _ufCtrl = TextEditingController();
  final _complementoCtrl = TextEditingController();
  final _pontoReferenciaCtrl = TextEditingController();
  String _sexoSelecionado = 'M';
  String _tipoContribuinte = 'N';

  final _cnpjMask = MaskTextInputFormatter(mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});
  final _dataNascimentoMask = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  bool get _isEdicao => widget.clienteId != null;
  bool _isLoading = true;

  // Spacing constants
  static const double _gapSm = 8;
  static const double _gapMd = 16;

  @override
  void initState() {
    super.initState();
    _sexoSelecionado = 'M';
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
    _dataNascimentoCtrl.dispose();
    _codFidelidadeCtrl.dispose();
    _sexoCtrl.dispose();
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
        await _loadClienteData();
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

  Future<void> _loadClienteData() async {
    try {
      final cliente = await _controller.buscarClientePorId(widget.clienteId!);
      if (cliente == null) throw Exception('Cliente não encontrado');
      _sexoSelecionado = (cliente.sexo ?? 'M').toUpperCase() == 'F' ? 'F' : 'M';
      _razaoSocialCtrl.text = cliente.nome ?? '';
      _nomeFantasiaCtrl.text = cliente.nomeSocial ?? '';
      _cnpjCtrl.text = _cnpjMask.maskText(cliente.cpf ?? '');
      _ieCtrl.text = cliente.ie ?? '';
      _telefoneCtrl.text = _telefoneMask.maskText(cliente.telefone?.numero ?? '');
      _emailCtrl.text = cliente.email ?? '';
      _dataNascimentoCtrl.text = cliente.dataNascimento ?? '';
      _codFidelidadeCtrl.text = cliente.cod_fidelidade ?? '';
      _sexoCtrl.text = cliente.sexo ?? '';
      _cepCtrl.text = _cepMask.maskText(cliente.endereco?.cep ?? '');
      _logradouroCtrl.text = cliente.endereco?.logradouro ?? '';
      _numeroCtrl.text = cliente.endereco?.numero ?? '';
      _bairroCtrl.text = cliente.endereco?.bairro ?? '';
      _cidadeCtrl.text = cliente.endereco?.cidade ?? '';
      _ufCtrl.text = cliente.endereco?.uf ?? '';
      _complementoCtrl.text = cliente.endereco?.complemento ?? '';
      _pontoReferenciaCtrl.text = cliente.endereco?.pontoReferencia ?? '';
      _tipoContribuinte = cliente.situacao_ie ?? 'N';

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar Cliente: $e', style: TextStyle(color: cs.onError)),
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
      final clienteMap = {
        "id": widget.clienteId,
        "nome_razao": _razaoSocialCtrl.text,
        "email": _emailCtrl.text,
        "cpf_cnpj": _cnpjCtrl.text,
        "rg_ie": _ieCtrl.text,
        "data_nascimento": _dataNascimentoCtrl.text,
        "cod_fidelidade": _codFidelidadeCtrl.text,
        "sexo": _sexoCtrl.text,
        "tipo_pessoa": "F",
        "situacao_ie": _tipoContribuinte, // <-- aqui vai N, I ou C
        "fornecedor": false,
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
        await _controller.atualizarCliente(clienteMap);
        if (!mounted) return;
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente atualizado com sucesso!', style: TextStyle(color: cs.onPrimary)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      // Cadastro novo cliente
      try {
        // Tenta validar existência do cliente
        await _controller.validarExistenciaDoCliente(_cnpjCtrl.text);

        // Se não lançar exceção, o cliente já está cadastrado e vinculado
        if (!mounted) return;
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente já está na nossa base de dados e vinculado à sua empresa.', style: TextStyle(color: cs.onError)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isLoading = false);
        return;
      } on ClienteControllerException catch (e) {
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
        // Se lançar qualquer outra exceção, significa que o cliente não existe e pode ser cadastrado
        // Continua para cadastrarCliente
      }

      // Se chegou aqui, pode cadastrar o cliente normalmente
      await _controller.cadastrarCliente(clienteMap);

      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente cadastrado com sucesso!', style: TextStyle(color: cs.onPrimary)),
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
              Navigator.of(context).pushReplacementNamed('/listClientes');
            }
          },
        ),
        title: Text(
          _isEdicao ? 'Editar Cliente' : 'Cadastrar Cliente',
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
            _buildLabel('Nome / Razão'),
            _buildTextField(_razaoSocialCtrl, 'Digite o nome ou razão social do cliente', validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null),
            const SizedBox(height: _gapMd),

            _buildLabel('Nome Social (apelido)'),
            _buildTextField(_nomeFantasiaCtrl, 'Digite o nome social (apelido)'),
            const SizedBox(height: _gapMd),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CPF/CNPJ'),
                      _buildTextField(_cnpjCtrl, 'Digite o CPF ou CNPJ', keyboardType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)], validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null),
                    ],
                  ),
                ),
                const SizedBox(width: _gapSm),
                Expanded(
                  flex: 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('RG/IE'), _buildTextField(_ieCtrl, 'Digite o RG ou IE')]),
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

            // Campos movidos para antes do endereço
            _buildLabel('Sexo'),
            DropdownButtonFormField<String>(
              value: _sexoSelecionado,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Masculino')),
                DropdownMenuItem(value: 'F', child: Text('Feminino')),
              ],
              onChanged: (valor) {
                setState(() {
                  _sexoSelecionado = valor ?? 'M';
                });
              },
            ),
            const SizedBox(height: _gapMd),

            _buildLabel('Data de Nascimento'),
            _buildTextField(_dataNascimentoCtrl, 'dd/mm/aaaa', keyboardType: TextInputType.number, formatters: [_dataNascimentoMask]),
            const SizedBox(height: _gapMd),

            _buildLabel('Código Fidelidade'),
            _buildTextField(_codFidelidadeCtrl, 'Digite o código fidelidade'),
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

            // Endereço
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
                child: Text(_isEdicao ? 'Atualizar Cliente' : 'Cadastrar Cliente'),
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
