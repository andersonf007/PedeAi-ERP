import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';

class AberturaCaixaPage extends StatefulWidget {
  const AberturaCaixaPage({super.key});

  @override
  State<AberturaCaixaPage> createState() => _AberturaCaixaPageState();
}

class _AberturaCaixaPageState extends State<AberturaCaixaPage> {
  final TextEditingController _controller = TextEditingController();
  CaixaCotroller _caixaController = CaixaCotroller();
  String? periodo;
  double? valorAbertura = 0.00;
  bool caixaAberto = false;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _verificarCaixaAberto();
  }

  Future<void> _verificarCaixaAberto() async {
    setState(() => carregando = true);
    try {
      int idCaixa = await _caixaController.buscarCaixaAberto();
      setState(() {
        caixaAberto = idCaixa != -1;
        carregando = false;
      });
    } on CaixaCotrollerException {
      setState(() {
        caixaAberto = false;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        caixaAberto = false;
        carregando = false;
      });
    }
  }

  String _formatMoney(String value) {
    value = value.replaceAll(RegExp(r'[^0-9,.]'), '');
    value = value.replaceAll(',', '.');
    double? val = double.tryParse(value);
    if (val == null) return 'R\$ 0,00';
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(val);
  }

  String _getPeriodo(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return 'Manhã';
    if (hour >= 12 && hour < 18) return 'Tarde';
    return 'Noite';
  }

  void _confirmar() async {
    String valor = _controller.text.replaceAll(',', '.');
    valorAbertura = double.tryParse(valor) ?? 0.0;
    int id_caixa = await _caixaController.abrirCaixa(valorAbertura!, _getPeriodo(DateTime.now()));
    if (id_caixa != -1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abertura: R\$ ${valorAbertura!.toStringAsFixed(2)} - Período: ${_getPeriodo(DateTime.now())}'), backgroundColor: Colors.green));
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abertura De Caixa'), backgroundColor: Colors.orange),
      body: Center(
        child: carregando
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (caixaAberto)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          'O caixa já está aberto!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (!caixaAberto) ...[
                      Text('Valor de abertura', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [],
                        decoration: InputDecoration(
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          hintText: '0,00',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        _formatMoney(_controller.text),
                        style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                    SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: caixaAberto || _controller.text.isEmpty ? null : _confirmar,
                      child: Text('Confirmar', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
