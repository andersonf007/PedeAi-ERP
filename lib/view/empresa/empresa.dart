import 'package:flutter/material.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/view/empresa/empresaEditarDialog.dart';

class EmpresaPage extends StatefulWidget {
  const EmpresaPage({Key? key}) : super(key: key);

  @override
  State<EmpresaPage> createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  EmpresaController controladorEmpresa = EmpresaController();
  Empresa? empresa;
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarEmpresa();
  }

  Future<void> carregarEmpresa() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      // Tenta buscar no SharedPreferences
      empresa = await controladorEmpresa.getEmpresaFromSharedPreferences();

      // Se não encontrar, busca no banco e salva no SharedPreferences
      if (empresa == null) {
        // Aqui você pode definir o id da empresa conforme sua lógica
        int idEmpresa = 1; // Exemplo: id fixo ou obtido de outro lugar
        final dados = await controladorEmpresa.buscarDadosDaEmpresa(idEmpresa);
        empresa = Empresa.fromJson(dados);
      }

      setState(() {
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Erro ao carregar dados da empresa: $e';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquemaCores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados da Empresa'),
        backgroundColor: esquemaCores.primary,
        foregroundColor: esquemaCores.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: empresa == null
                ? null
                : () async {
                    final alterado = await showDialog<bool>(
                      context: context,
                      builder: (context) => EmpresaEditarDialog(empresa: empresa!),
                    );
                    if (alterado == true) {
                      await carregarEmpresa();
                    }
                  },
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Text(
                erro!,
                style: TextStyle(color: esquemaCores.error, fontWeight: FontWeight.bold),
              ),
            )
          : empresa == null
          ? Center(
              child: Text('Nenhuma empresa encontrada.', style: TextStyle(color: esquemaCores.onSurface.withOpacity(0.7))),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  _linha('Nome fantasia', empresa!.fantasia),
                  _linha('Razão social', empresa!.razao),
                  _linha('CNPJ', empresa!.cnpj),
                  _linha('E-mail', empresa!.email),
                  _linha('Telefone', empresa!.telefone),
                  const SizedBox(height: 16),
                  Text('Endereço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  _linha('Logradouro', empresa!.logradouro),
                  _linha('Número', empresa!.numero),
                  _linha('Bairro', empresa!.bairro),
                  _linha('Município', empresa!.municipio),
                  _linha('UF', empresa!.uf),
                  _linha('CEP', empresa!.cep),
                  const SizedBox(height: 16),
                  _linha('Schema', empresa!.schema),
                ],
              ),
            ),
    );
  }

  Widget _linha(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$titulo:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
