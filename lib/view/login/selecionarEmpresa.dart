import 'package:flutter/material.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';

class SelecionarEmpresaPage extends StatefulWidget {
  final List<Map<String, dynamic>> empresas;
  // cada item: { 'schema': 'schema1', 'id': 1, 'fantasia': 'Empresa X' }

  const SelecionarEmpresaPage({super.key, required this.empresas});

  @override
  State<SelecionarEmpresaPage> createState() => _SelecionarEmpresaPageState();
}

class _SelecionarEmpresaPageState extends State<SelecionarEmpresaPage> {
  Map<String, dynamic>? _empresaSelecionada;

  @override
  Widget build(BuildContext context) {
    final empresaController = EmpresaController();

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Empresa'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: _empresaSelecionada,
              hint: const Text('Selecione uma empresa'),
              items: widget.empresas.map((empresa) {
                return DropdownMenuItem(value: empresa, child: Text(empresa['fantasia'] ?? ''));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _empresaSelecionada = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _empresaSelecionada == null
                  ? null
                  : () async {
                      try {
                        await empresaController.buscarDadosDaEmpresa(_empresaSelecionada!['id']);

                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar empresa: $e')));
                        }
                      }
                    },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
