import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pedeai/controller/clienteController.dart';
import 'package:pedeai/utils/app_notify.dart';

class CadastroClienteDialog extends StatefulWidget {
  final String cpf;
  const CadastroClienteDialog({required this.cpf});

  @override
  State<CadastroClienteDialog> createState() => _CadastroClienteDialogState();
}

class _CadastroClienteDialogState extends State<CadastroClienteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ClienteController();

  final _razaoSocialCtrl = TextEditingController();
  final _nomeFantasiaCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _ieCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dataNascimentoCtrl = TextEditingController();
  final _codFidelidadeCtrl = TextEditingController();
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

  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _dataNascimentoMask = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final _cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    _cnpjCtrl.text = widget.cpf;
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final clienteMap = {
        "nome_razao": _razaoSocialCtrl.text,
        "email": _emailCtrl.text,
        "cpf_cnpj": _cnpjCtrl.text,
        "rg_ie": _ieCtrl.text,
        "data_nascimento": _dataNascimentoCtrl.text,
        "cod_fidelidade": _codFidelidadeCtrl.text,
        "sexo": _sexoSelecionado,
        "tipo_pessoa": "F",
        "situacao_ie": _tipoContribuinte,
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
      final novoId = await _controller.cadastrarCliente(clienteMap);
      if (!mounted) return;
      Navigator.of(context).pop(novoId);
    } catch (e) {
      AppNotify.error(context, 'Erro ao cadastrar cliente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar Cliente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _razaoSocialCtrl,
                decoration: const InputDecoration(labelText: 'Nome / Razão'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeFantasiaCtrl,
                decoration: const InputDecoration(labelText: 'Nome Social (apelido)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cnpjCtrl,
                decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)],
                validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ieCtrl,
                decoration: const InputDecoration(labelText: 'RG/IE'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefoneCtrl,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.number,
                inputFormatters: [_telefoneMask],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dataNascimentoCtrl,
                decoration: const InputDecoration(labelText: 'Data de Nascimento'),
                keyboardType: TextInputType.number,
                inputFormatters: [_dataNascimentoMask],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codFidelidadeCtrl,
                decoration: const InputDecoration(labelText: 'Código Fidelidade'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _sexoSelecionado,
                decoration: const InputDecoration(labelText: 'Sexo'),
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
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoContribuinte,
                decoration: const InputDecoration(labelText: 'Tipo de Contribuinte'),
                items: const [
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
              const Divider(),
              TextFormField(
                controller: _cepCtrl,
                decoration: const InputDecoration(labelText: 'CEP'),
                keyboardType: TextInputType.number,
                inputFormatters: [_cepMask],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _logradouroCtrl,
                decoration: const InputDecoration(labelText: 'Logradouro'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _numeroCtrl,
                      decoration: const InputDecoration(labelText: 'Número'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _bairroCtrl,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cidadeCtrl,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _ufCtrl,
                      decoration: const InputDecoration(labelText: 'UF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _complementoCtrl,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pontoReferenciaCtrl,
                decoration: const InputDecoration(labelText: 'Ponto de Referência'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
