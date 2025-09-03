import 'package:flutter/material.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/controller/vendaController.dart';
import 'package:pedeai/theme/color_tokens.dart';

class VendaDetalhePage extends StatefulWidget {
  final int idVenda;
  const VendaDetalhePage({Key? key, required this.idVenda}) : super(key: key);

  @override
  State<VendaDetalhePage> createState() => _VendaDetalhePageState();
}

class _VendaDetalhePageState extends State<VendaDetalhePage> {
  final VendaController controladorVenda = VendaController();

  bool carregando = true;
  String? erro;

  Map<String, dynamic>? venda;
  List<Map<String, dynamic>> itens = [];
  List<Map<String, dynamic>> pagamentos = [];
  bool caixaAberto = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      // Busca dados da venda
      final dadosVendaList = await controladorVenda.buscarDadosDaVenda(widget.idVenda);
      venda = dadosVendaList.isNotEmpty ? dadosVendaList.first : {};

      // Busca itens
      itens = await controladorVenda.buscarItensDaVenda(widget.idVenda);

      // Busca formas de pagamento
      pagamentos = await controladorVenda.buscarFormasDePagamentoDaVenda(widget.idVenda);

      // Verifica se o caixa está aberto
      caixaAberto = venda?['aberto'] == true;

      setState(() {
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Falha ao carregar venda: $e';
        carregando = false;
      });
    }
  }

  double get subtotal {
    double total = 0.0;
    for (final item in itens) {
      final preco = item['preco_total'] ?? 0.0;
      total += (preco is num) ? preco.toDouble() : double.tryParse(preco.toString()) ?? 0.0;
    }
    return total;
  }

  double get desconto {
    final valor = venda?['desconto'];
    if (valor == null) return 0.0;
    return (valor is num) ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0.0;
  }

  double get acrescimo {
    final valor = venda?['acrescimo'];
    if (valor == null) return 0.0;
    return (valor is num) ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0.0;
  }

  double get total {
    final valor = venda?['valor_total'];
    if (valor == null) return 0.0;
    return (valor is num) ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0.0;
  }

  String formatarMoeda(double valor) => 'R\$ ${valor.toStringAsFixed(2)}';

  String formatarData(dynamic raw) {
    if (raw == null) return '—';
    DateTime? d;
    if (raw is DateTime)
      d = raw;
    else
      d = DateTime.tryParse(raw.toString());
    if (d == null) return raw.toString();
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final esquemaCores = Theme.of(context).colorScheme;
    print(venda);
    final id = venda?['id'] ?? '—';
    final dataAbertura = formatarData(venda?['data_abertura']);
    final cliente = venda?['nome_cliente'] ?? venda?['cliente'] ?? '—';
    final cpfCliente = venda?['cpf_cliente'] ?? '';
    final statusRaw = venda?['situacao'] ?? venda?['descricao'] ?? venda?['status'] ?? venda?['situacao'] ?? '';
    final status = statusRaw.toString().isEmpty ? 'Situação não identificada' : statusRaw.toString();

    Color corStatus;
    if (status == 'Fechada') {
      corStatus = Colors.green;
    } else if (status == 'Cancelada') {
      corStatus = Colors.red;
    } else {
      corStatus = Colors.blue;
    }

    return Scaffold(
      backgroundColor: esquemaCores.surface,
      appBar: AppBar(
        backgroundColor: esquemaCores.surface,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: esquemaCores.onSurface),
        title: Text(
          '#$id',
          style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar: AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: carregando
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
          : RefreshIndicator(
              onRefresh: () async => _carregarDados(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  // Header resumo
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(esquemaCores.primary.withOpacity(.08), esquemaCores.surface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: esquemaCores.onSurface.withOpacity(.10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: corStatus, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: TextStyle(color: corStatus, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text('• $dataAbertura', style: TextStyle(color: esquemaCores.onSurface.withOpacity(.75))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliente: $cliente',
                          style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text('CPF do cliente: $cpfCliente', style: TextStyle(color: esquemaCores.onSurface.withOpacity(.85))),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${formatarMoeda(total)}',
                          style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Resumo financeiro
                  _CardSection(
                    title: 'Resumo',
                    child: Column(children: [linhaResumoFinanceiro('Subtotal', formatarMoeda(subtotal), esquemaCores), linhaResumoFinanceiro('Desconto', '- ${formatarMoeda(desconto)}', esquemaCores, diminuir: true), linhaResumoFinanceiro('Total', formatarMoeda(total), esquemaCores, negrito: true)]),
                  ),

                  const SizedBox(height: 12),

                  // Pagamentos
                  _CardSection(
                    title: 'Pagamentos',
                    child: pagamentos.isEmpty
                        ? Text('Nenhuma forma de pagamento registrada.', style: TextStyle(color: esquemaCores.onSurface.withOpacity(.70)))
                        : Column(
                            children: [
                              ...pagamentos.map((p) {
                                final nome = p['nome'] ?? p['forma'] ?? p['forma_nome'] ?? 'Forma';
                                final valor = p['valor'] ?? 0.0;
                                final troco = p['troco'] ?? 0.0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('$nome', style: TextStyle(color: esquemaCores.onSurface.withOpacity(.90))),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatarMoeda((valor is num) ? valor.toDouble() : double.tryParse(valor.toString()) ?? 0.0),
                                            style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.w700),
                                          ),
                                          if ((troco is num ? troco : double.tryParse(troco.toString()) ?? 0.0) > 0)
                                            Text(
                                              'Troco ${formatarMoeda((troco is num) ? troco.toDouble() : double.tryParse(troco.toString()) ?? 0.0)}',
                                              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Itens
                  _CardSection(
                    title: 'Itens',
                    child: itens.isEmpty
                        ? Text('Nenhum item na venda.', style: TextStyle(color: esquemaCores.onSurface.withOpacity(.70)))
                        : Column(
                            children: itens.map((it) {
                              final nome = it['descricao'] ?? it['produto'] ?? '—';
                              final qtd = it['quantidade'] ?? 0;
                              final unit = formatarMoeda(it['preco_unitario'] ?? 0.0);
                              final tot = formatarMoeda(it['preco_total'] ?? 0.0);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nome,
                                            style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 2),
                                          Text('$qtd x $unit', style: TextStyle(color: esquemaCores.onSurface.withOpacity(.70), fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tot,
                                      style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Botão cancelar venda
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (caixaAberto && status == 'Fechada')
                          ? () async {
                              try {
                                await controladorVenda.cancelarVenda(widget.idVenda);
                                await _carregarDados();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venda cancelada com sucesso!'), backgroundColor: Colors.green));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cancelar venda: $e'), backgroundColor: Colors.red));
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar venda', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final esquemaCores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esquemaCores.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esquemaCores.onSurface.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: esquemaCores.onSurface, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

Widget linhaResumoFinanceiro(String rotulo, String valor, ColorScheme esquemaCores, {bool negrito = false, bool diminuir = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo, style: TextStyle(color: esquemaCores.onSurface.withOpacity(diminuir ? .70 : .90))),
        Text(
          valor,
          style: TextStyle(color: diminuir ? esquemaCores.onSurface.withOpacity(.80) : esquemaCores.onSurface, fontWeight: negrito ? FontWeight.w800 : FontWeight.w600),
        ),
      ],
    ),
  );
}
