import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';

class EmpresaEditarDialog extends StatefulWidget {
  final Empresa empresa;
  const EmpresaEditarDialog({super.key, required this.empresa});

  @override
  State<EmpresaEditarDialog> createState() => _EmpresaEditarDialogState();
}

class _EmpresaEditarDialogState extends State<EmpresaEditarDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController cnpj;
  late final TextEditingController razao;
  late final TextEditingController fantasia;
  late final TextEditingController cep;
  late final TextEditingController logradouro;
  late final TextEditingController numero;
  late final TextEditingController bairro;
  late final TextEditingController municipio;
  late final TextEditingController uf;
  late final TextEditingController telefone;
  late final TextEditingController email;

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
  void dispose() {
    cnpj.dispose();
    razao.dispose();
    fantasia.dispose();
    cep.dispose();
    logradouro.dispose();
    numero.dispose();
    bairro.dispose();
    municipio.dispose();
    uf.dispose();
    telefone.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    InputDecoration _dec(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: cs.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        );

    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Editar Empresa',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
      content: carregando
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dados principais
                    TextFormField(
                      controller: fantasia,
                      decoration: _dec('Nome fantasia'),
                      textInputAction: TextInputAction.next,
                      validator: _req,
                      autofocus: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: razao,
                      decoration: _dec('Razão social'),
                      textInputAction: TextInputAction.next,
                      validator: _req,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: cnpj,
                      decoration: _dec('CNPJ'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\./-]')),
                        LengthLimitingTextInputFormatter(18),
                      ],
                      validator: _req,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: email,
                      decoration: _dec('E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validaEmail,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: telefone,
                      decoration: _dec('Telefone'),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-\(\)\+]')),
                        LengthLimitingTextInputFormatter(20),
                      ],
                      validator: _req,
                    ),
                    const SizedBox(height: 16),

                    // Endereço
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Endereço',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          )),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: logradouro,
                      decoration: _dec('Logradouro'),
                      textInputAction: TextInputAction.next,
                      validator: _req,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: numero,
                            decoration: _dec('Número'),
                            keyboardType: TextInputType.text,
                            validator: _req,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: bairro,
                            decoration: _dec('Bairro'),
                            validator: _req,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: municipio,
                            decoration: _dec('Município'),
                            validator: _req,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: uf,
                            decoration: _dec('UF'),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                              LengthLimitingTextInputFormatter(2),
                              UpperCaseTextFormatter(),
                            ],
                            validator: (v) =>
                                (v == null || v.trim().length != 2) ? 'UF inválida' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: cep,
                      decoration: _dec('CEP'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      validator: _req,
                    ),

                    if (erro != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          erro!,
                          style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      actions: [
        TextButton(
          onPressed: carregando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: carregando
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() {
                    carregando = true;
                    erro = null;
                  });
                  try {
                    final empresaAtualizada = {
                      'id': widget.empresa.id,
                      'cnpj': cnpj.text.trim(),
                      'razao': razao.text.trim(),
                      'fantasia': fantasia.text.trim(),
                      'cep': cep.text.trim(),
                      'logradouro': logradouro.text.trim(),
                      'numero': numero.text.trim(),
                      'bairro': bairro.text.trim(),
                      'municipio': municipio.text.trim(),
                      'uf': uf.text.trim().toUpperCase(),
                      'telefone': telefone.text.trim(),
                      'email': email.text.trim(),
                      'schema': widget.empresa.schema,
                    };
                    await EmpresaController().atualizarDadosEmpresa(empresaAtualizada);
                    if (!mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    setState(() {
                      erro = 'Erro ao salvar: $e';
                      carregando = false;
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(96, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: carregando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  // ------- validators / formatters -------
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validaEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
    final s = v.trim();
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    return ok ? null : 'E-mail inválido';
  }
}

/// Formatter simples para forçar maiúsculas (UF)
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
