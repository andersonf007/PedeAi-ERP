import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';

class DetalhamentoDoCaixaPage extends StatefulWidget {
  final int idCaixa;
  const DetalhamentoDoCaixaPage({Key? key, required this.idCaixa}) : super(key: key);

  @override
  State<DetalhamentoDoCaixaPage> createState() => _DetalhamentoDoCaixaPageState();
}

class _DetalhamentoDoCaixaPageState extends State<DetalhamentoDoCaixaPage> {
  Map<String, dynamic>? _dadosCaixa;
  List<Map<String, dynamic>> _formasPagamento = [];
  double _receitaPdv = 0.0;
  int _qtdVendasPdv = 0;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final caixaController = CaixaCotroller();

      // Busca dados principais do caixa
      final caixa = await caixaController.buscarDadosDoCaixa(widget.idCaixa);

      // Busca formas de pagamento recebidas no caixa
      final formasPagamento = await caixaController.buscarPagamentosRealizadosNoCaixa(widget.idCaixa);

      // Busca receita PDV e quantidade de vendas PDV
      final receitaPdvResult = await caixaController.buscarReceitaDoPdvDoCaixa(widget.idCaixa);
      double receitaPdv = 0.0;
      int qtdVendasPdv = 0;
      if (receitaPdvResult.isNotEmpty) {
        receitaPdv = receitaPdvResult['valor']?.toDouble() ?? 0.0;
        qtdVendasPdv = receitaPdvResult['total_de_vendas'] as int? ?? 0;
      }
      double saldoAtual = 0.0;
      for (final forma in formasPagamento) {
        saldoAtual += (forma['valor'] as num?)?.toDouble() ?? 0.0;
      }
      setState(() {
        _dadosCaixa = {
          'id': caixa!.id,
          'data_abertura': caixa.dataAbertura,
          'hora_abertura': caixa.periodoAbertura,
          'usuario_abertura': caixa.usuarioAbertura,
          'data_fechamento': caixa.dataFechamento,
          'hora_fechamento': caixa.periodoFechamento,
          'usuario_fechamento': caixa.usuarioFechamento,
          'status': caixa.aberto == true ? 'ABERTO' : 'FECHADO',
          'valor_inicial': caixa.valorAbertura ?? 0.0,
          'saldo_final': saldoAtual ?? 0.0,
        };
        _formasPagamento = formasPagamento;
        _receitaPdv = receitaPdv;
        _qtdVendasPdv = qtdVendasPdv;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao buscar detalhes do caixa: $e';
        _carregando = false;
      });
    }
  }

  String _formatarData(dynamic data) {
    if (data == null) return '';
    final d = DateTime.tryParse(data.toString());
    if (d == null) return data.toString();
    return DateFormat('dd/MM/yyyy').format(d);
  }

  String _formatarValor(dynamic valor) {
    if (valor == null) return 'R\$ 0,00';
    return 'R\$ ${valor is num ? valor.toStringAsFixed(2) : valor}';
  }

  String _formatarDataHora(dynamic data) {
    if (data == null || data.toString().isEmpty) return '';
    String dataFormatada;
    try {
      dataFormatada = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(data.toString()));
    } catch (_) {
      dataFormatada = data.toString();
    }
    return '$dataFormatada';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhamento do Caixa'), backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(
              child: Text(_erro!, style: TextStyle(color: cs.error)),
            )
          : _dadosCaixa == null
          ? Center(child: Text('Nenhum dado encontrado.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Caixa #${_dadosCaixa!['id']}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Abertura: ${_formatarDataHora(_dadosCaixa!['data_abertura'])}'), Text('Fechamento: ${_formatarDataHora(_dadosCaixa!['data_fechamento'])}')]),
                  const SizedBox(height: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Aberto por: ${_dadosCaixa!['usuario_abertura'] ?? ''}'), Text('Fechado por: ${_dadosCaixa!['usuario_fechamento'] ?? ''}')]),
                  const SizedBox(height: 8),
                  Text('Status: ${_dadosCaixa!['status'] ?? ''}'),
                  const Divider(height: 24),
                  Text('Valor inicial: ${_formatarValor(_dadosCaixa!['valor_inicial'])}'),
                  const SizedBox(height: 8),
                  Text('Receita PDV: ${_formatarValor(_receitaPdv)}'),
                  Text('Quantidade de vendas PDV: $_qtdVendasPdv'),
                  const Divider(height: 24),
                  Text('Formas de pagamento recebidas:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._formasPagamento.map((fp) => _linhaResumo(fp['nome'] ?? '', _formatarValor(fp['valor']))),
                  const Divider(height: 24),
                  _linhaResumo('Suprimento (+)', _formatarValor(0.0)),
                  _linhaResumo('Retirada (-)', _formatarValor(0.0)),
                  _linhaResumo('Outros créditos (+)', _formatarValor(0.0)),
                  _linhaResumo('Outros débitos (-)', _formatarValor(0.0)),
                  _linhaResumo('Estorno de vendas', _formatarValor(0.0)),
                  const Divider(height: 24),
                  Text('Saldo final: ${_formatarValor(_dadosCaixa!['saldo_final'])}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary)),
                ],
              ),
            ),
    );
  }

  Widget _linhaResumo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
