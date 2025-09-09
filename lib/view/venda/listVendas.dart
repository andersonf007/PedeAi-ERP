import 'package:flutter/material.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/controller/vendaController.dart';
import 'package:pedeai/theme/color_tokens.dart';
import 'package:pedeai/utils/caixa_helper.dart';

class ListagemVendasPage extends StatefulWidget {
  const ListagemVendasPage({Key? key}) : super(key: key);

  @override
  State<ListagemVendasPage> createState() => _ListagemVendasPageState();
}

class _ListagemVendasPageState extends State<ListagemVendasPage> {
  final VendaController vendaController = VendaController();

  bool carregando = true;
  String? erro;
  DateTime dataInicial = DateTime.now();
  DateTime dataFinal = DateTime.now();
  List<Map<String, dynamic>> vendas = [];

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    dataInicial = DateTime(agora.year, agora.month, 1);
    dataFinal = agora;
    buscarVendas();
  }

  Future<void> buscarVendas() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      vendas = await vendaController.listarVendas(
        inicio: dataInicial,
        fim: dataFinal,
      );
      setState(() {
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Falha ao carregar vendas: $e';
        carregando = false;
      });
    }
  }

  int get quantidadeVendas => vendas.length;

  double get valorTotalVendas {
    double total = 0.0;
    for (final venda in vendas) {
      final status = venda['descricao']?.toString() ?? '';
      if (status == 'Fechada') {
        final valor = venda['valor_total'] ?? venda['valor'] ?? 0;
        total += (valor is num)
            ? valor.toDouble()
            : double.tryParse(valor.toString()) ?? 0.0;
      }
    }
    return total;
  }

  String formatarData(DateTime data) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} ${dois(data.hour)}:${dois(data.minute)}';
  }

  String formatarMoeda(double valor) => 'R\$ ${valor.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final esquemaCores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: esquemaCores.surface,
      appBar: AppBar(
        backgroundColor: esquemaCores.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Vendas',
          style: TextStyle(
            color: esquemaCores.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: esquemaCores.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: Icon(Icons.refresh, color: esquemaCores.onSurface),
            onPressed: buscarVendas,
          ),
          IconButton(
            tooltip: 'Filtrar por período',
            icon: Icon(Icons.calendar_today, color: esquemaCores.onSurface),
            onPressed: () async {
              final intervalo = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2022, 1, 1),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: dataInicial,
                  end: dataFinal,
                ),
              );
              if (intervalo != null) {
                setState(() {
                  dataInicial = intervalo.start;
                  dataFinal = intervalo.end;
                });
                buscarVendas();
              }
            },
          ),
        ],
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar: AppNavBar(
        currentRoute: ModalRoute.of(context)?.settings.name,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _ResumoTile(
                    rotulo: 'Quantidade de vendas',
                    valor: '$quantidadeVendas',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResumoTile(
                    rotulo: 'Valor total',
                    valor: formatarMoeda(valorTotalVendas),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : erro != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        erro!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: esquemaCores.error),
                      ),
                    ),
                  )
                : vendas.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma venda encontrada',
                      style: TextStyle(
                        color: esquemaCores.onSurface.withOpacity(.7),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: buscarVendas,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: vendas.length,
                      itemBuilder: (context, indice) {
                        final venda = vendas[indice];
                        final idVenda = venda['id'] ?? '—';
                        final dataAbertura = venda['data_abertura'];
                        final valorTotal = venda['valor_total'] ?? 0.0;
                        final status = venda['descricao'] ?? '—';

                        Color corStatus;
                        if (status.toString() == 'Fechada') {
                          corStatus = Colors.green;
                        } else if (status.toString() == 'Cancelada') {
                          corStatus = Colors.red;
                        } else {
                          corStatus = Colors.blue;
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/venda-detalhe',
                              arguments: {'idVenda': idVenda},
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: esquemaCores.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: esquemaCores.onSurface.withOpacity(.10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '#$idVenda',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: esquemaCores.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dataAbertura != null
                                            ? formatarData(
                                                DateTime.tryParse(
                                                      dataAbertura.toString(),
                                                    ) ??
                                                    DateTime.now(),
                                              )
                                            : 'Data não informada',
                                        style: TextStyle(
                                          color: esquemaCores.onSurface
                                              .withOpacity(.70),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$status',
                                        style: TextStyle(
                                          color: corStatus,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  formatarMoeda(
                                    (valorTotal is num)
                                        ? valorTotal.toDouble()
                                        : double.tryParse(
                                                valorTotal.toString(),
                                              ) ??
                                              0.0,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: esquemaCores.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: esquemaCores.primary,
                    foregroundColor: esquemaCores.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                onPressed: () async {
                  await CaixaHelper.verificarCaixaAbertoENavegar(
                    context,
                    '/pdv',
                  );
                },
                child: const Text('Nova venda'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoTile extends StatelessWidget {
  const _ResumoTile({required this.rotulo, required this.valor});
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final esquemaCores = Theme.of(context).colorScheme;
    final temaTexto = Theme.of(context).textTheme;
    final corFundo = Color.alphaBlend(
      esquemaCores.primary.withOpacity(.08),
      esquemaCores.surface,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esquemaCores.onSurface.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: temaTexto.labelSmall?.copyWith(
              color: esquemaCores.onSurface.withOpacity(.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: temaTexto.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: esquemaCores.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
