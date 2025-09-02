import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';

class FechamentoCaixaPage extends StatefulWidget {
  const FechamentoCaixaPage({super.key});

  @override
  State<FechamentoCaixaPage> createState() => _FechamentoCaixaPageState();
}

class _FechamentoCaixaPageState extends State<FechamentoCaixaPage> {
  final CaixaCotroller _caixaController = CaixaCotroller();

  var caixa;
  List<Map<String, dynamic>> pagamentos = [];
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      loading = true;
      erro = null;
    });
    try {
      final idCaixa = await _caixaController.buscarCaixaAberto();
      if (idCaixa == null) throw CaixaCotrollerException('Caixa não encontrado.');
      caixa = await _caixaController.buscarDadosDoCaixa(idCaixa);
      pagamentos = await _caixaController.buscarPagamentosRealizadosNoCaixa(idCaixa);
    } on CaixaCotrollerException catch (e) {
      erro = e.message;
    } catch (e) {
      erro = 'Erro inesperado: $e';
    }
    setState(() => loading = false);
  }

  String formatData(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
  }

  String formatMoeda(num v) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
  }

  String _getPeriodo(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return 'Manhã';
    if (hour >= 12 && hour < 18) return 'Tarde';
    return 'Noite';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fechamento De Caixa')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(12)),
                child: Text(
                  erro!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dados do caixa', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Data de abertura:'),
                            Text(formatData(caixa.dataAbertura), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Valor de abertura:'),
                            Text(formatMoeda(caixa.valorAbertura), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pagamentos', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: pagamentos.isEmpty
                      ? const Padding(padding: EdgeInsets.all(16), child: Text('Nenhum pagamento encontrado.'))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pagamentos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final row = pagamentos[i];
                            return ListTile(
                              title: Text(row['nome'] ?? 'Forma'),
                              trailing: Text(formatMoeda(row['valor'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    print('Fechar caixa pressed');
                    print(pagamentos);
                    try {
                      // Monta lista de pagamentos
                      List<Map<String, dynamic>> pagamentosMap = pagamentos.map((p) => {'id_caixa': caixa.id, 'id_forma_de_pagamento': p['id'], 'valor': p['valor'], 'tipo_forma_pagamento_id': p['tipo_forma_pagamento_id']}).toList();

                      // Monta dados do caixa
                      Map<String, dynamic> dadosCaixa = {
                        'id': caixa.id,
                        'aberto': false,
                        'data_fechamento': DateTime.now().toIso8601String(),
                        'periodo_fechamento': _getPeriodo(DateTime.now()),
                        'id_usuario_fechamento': '', // será preenchido no controller
                      };

                      await _caixaController.fecharCaixa(pagamentosMap, dadosCaixa);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Caixa fechado com sucesso!'), backgroundColor: Colors.green));
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao fechar caixa: $e'), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Fechar caixa'),
                ),
              ],
            ),
    );
  }
}
