import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';

class EmpresaEditarDialog extends StatefulWidget {
  final Empresa empresa;
  const EmpresaEditarDialog({required this.empresa});

  @override
  State<EmpresaEditarDialog> createState() => _EmpresaEditarDialogState();
}

class _EmpresaEditarDialogState extends State<EmpresaEditarDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController cnpj;
  late TextEditingController razao;
  late TextEditingController fantasia;
  late TextEditingController cep;
  late TextEditingController logradouro;
  late TextEditingController numero;
  late TextEditingController bairro;
  late TextEditingController municipio;
  late TextEditingController uf;
  late TextEditingController telefone;
  late TextEditingController email;

  bool carregando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    cnpj = TextEditingController(text: widget.empresa.cnpj);
    razao = TextEditingController(text: widget.empresa.razao);
    fantasia = TextEditingController(text: widget.empresa.fantasia);
    cep = TextEditingController(text: widget.empresa.cep);
    logradouro = TextEditingController(text: widget.empresa.logradouro);
    numero = TextEditingController(text: widget.empresa.numero);
    bairro = TextEditingController(text: widget.empresa.bairro);
    municipio = TextEditingController(text: widget.empresa.municipio);
    uf = TextEditingController(text: widget.empresa.uf);
    telefone = TextEditingController(text: widget.empresa.telefone);
    email = TextEditingController(text: widget.empresa.email);
  }

  @override
  Widget build(BuildContext context) {
    final esquemaCores = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Editar Empresa'),
      content: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _campo('Nome fantasia', fantasia),
                    _campo('Razão social', razao),
                    _campo('CNPJ', cnpj),
                    _campo('E-mail', email),
                    _campo('Telefone', telefone),
                    _campo('Logradouro', logradouro),
                    _campo('Número', numero),
                    _campo('Bairro', bairro),
                    _campo('Município', municipio),
                    _campo('UF', uf),
                    _campo('CEP', cep),
                    if (erro != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(erro!, style: TextStyle(color: esquemaCores.error)),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: carregando
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => carregando = true);
                  try {
                    final empresaAtualizada = {
                      'id': widget.empresa.id,
                      'cnpj': cnpj.text,
                      'razao': razao.text,
                      'fantasia': fantasia.text,
                      'cep': cep.text,
                      'logradouro': logradouro.text,
                      'numero': numero.text,
                      'bairro': bairro.text,
                      'municipio': municipio.text,
                      'uf': uf.text,
                      'telefone': telefone.text,
                      'email': email.text,
                      // Não envie o schema!
                    };
                    final controlador = EmpresaController();
                    await controlador.atualizarDadosEmpresa(empresaAtualizada);
                    Navigator.pop(context, true);
                  } catch (e) {
                    setState(() {
                      erro = 'Erro ao salvar: $e';
                      carregando = false;
                    });
                  }
                },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _campo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
      ),
    );
  }
}