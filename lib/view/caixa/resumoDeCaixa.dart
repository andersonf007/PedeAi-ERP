import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';

class ResumoDeCaixaPage extends StatefulWidget {
  const ResumoDeCaixaPage({Key? key}) : super(key: key);

  @override
  State<ResumoDeCaixaPage> createState() => _ResumoDeCaixaPageState();
}

class _ResumoDeCaixaPageState extends State<ResumoDeCaixaPage> {
  final CaixaCotroller _caixaController = CaixaCotroller();

  DateTime _dataInicial = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _dataFinal = DateTime.now();
  List<Map<String, dynamic>> _caixas = [];
  bool _carregando = false;
  String? _erro;
  int? _caixaSelecionado;

  @override
  void initState() {
    super.initState();
    _buscarCaixas();
  }

  Future<void> _buscarCaixas() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final caixas = await _caixaController.buscarDatasDosCaixas(_dataInicial, _dataFinal);
      setState(() {
        _caixas = caixas;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao buscar caixas: $e';
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

  Future<void> _selecionarDataInicial() async {
    final data = await showDatePicker(context: context, initialDate: _dataInicial, firstDate: DateTime(2022, 1, 1), lastDate: DateTime.now());
    if (data != null) {
      setState(() => _dataInicial = data);
      // Não chama _buscarCaixas aqui!
    }
  }

  Future<void> _selecionarDataFinal() async {
    final data = await showDatePicker(context: context, initialDate: _dataFinal, firstDate: _dataInicial, lastDate: DateTime.now());
    if (data != null) {
      setState(() => _dataFinal = data);
      // Não chama _buscarCaixas aqui!
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo de Caixa'), backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selecionarDataInicial,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Data inicial',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_dataInicial)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _selecionarDataFinal,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Data final',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_dataFinal)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _carregando ? null : _buscarCaixas,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(80, 48), padding: const EdgeInsets.symmetric(horizontal: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                ? Center(
                    child: Text(_erro!, style: TextStyle(color: cs.error)),
                  )
                : _caixas.isEmpty
                ? Center(
                    child: Text('Nenhum caixa encontrado.', style: TextStyle(color: cs.onSurface.withOpacity(.7))),
                  )
                : ListView.builder(
                    itemCount: _caixas.length,
                    itemBuilder: (context, index) {
                      final caixa = _caixas[index];
                      final selecionado = _caixaSelecionado == caixa['id'];
                      return Card(
                        color: selecionado ? cs.primary.withOpacity(0.08) : cs.surface,
                        child: ListTile(
                          title: Text('Caixa #${caixa['id']}'),
                          subtitle: Text(
                            'Abertura: ${_formatarData(caixa['data_abertura'])}\n'
                            'Fechamento: ${_formatarData(caixa['data_fechamento'])}',
                          ),
                          onTap: () {
                            setState(() {
                              _caixaSelecionado = caixa['id'];
                            });
                            Navigator.of(context).pushNamed('/detalhamentoCaixa', arguments: caixa['id']);
                          },
                          selected: selecionado,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
