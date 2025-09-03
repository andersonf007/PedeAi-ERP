import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedeai/controller/caixaController.dart';
import 'package:pedeai/utils/app_notify.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

class AberturaCaixaPage extends StatefulWidget {
  const AberturaCaixaPage({super.key});

  @override
  State<AberturaCaixaPage> createState() => _AberturaCaixaPageState();
}

class _AberturaCaixaPageState extends State<AberturaCaixaPage> {
  final TextEditingController _controller = TextEditingController();
  final CaixaCotroller _caixaController = CaixaCotroller();

  bool caixaAberto = false;
  bool carregando = true;
  bool abrindo = false;

  @override
  void initState() {
    super.initState();
    _verificarCaixaAberto();
  }

  Future<void> _verificarCaixaAberto() async {
    setState(() => carregando = true);
    try {
      final idCaixa = await _caixaController.buscarCaixaAberto();
      setState(() {
        caixaAberto = idCaixa != -1;
        carregando = false;
      });
    } on CaixaCotrollerException {
      setState(() {
        caixaAberto = false;
        carregando = false;
      });
    } catch (_) {
      setState(() {
        caixaAberto = false;
        carregando = false;
      });
    }
  }

  String _formatMoney(String value) {
    // normaliza entrada
    final only = value.replaceAll(RegExp(r'[^0-9,.]'), '').replaceAll(',', '.');
    final v = double.tryParse(only) ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);
  }

  String _periodoAgora(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 12) return 'Manhã';
    if (h >= 12 && h < 18) return 'Tarde';
    return 'Noite';
  }

  Future<void> _confirmar() async {
    final cs = Theme.of(context).colorScheme;

    final raw = _controller.text.replaceAll(',', '.');
    final valor = double.tryParse(raw) ?? 0.0;

    if (valor < 0) {
      AppNotify.error(context, 'Informe um valor válido.');
      return;
    }

    setState(() => abrindo = true);
    try {
      final periodo = _periodoAgora(DateTime.now());
      final idCaixa = await _caixaController.abrirCaixa(valor, periodo);

      if (idCaixa != -1) {
        AppNotify.success(
          context,
          'Caixa aberto: ${_formatMoney(valor.toString())} • $periodo',
        );
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
      } else {
        AppNotify.error(context, 'Não foi possível abrir o caixa.');
      }
    } catch (e) {
      if (!mounted) return;
      AppNotify.error(context, 'Erro ao abrir caixa: $e');
    } finally {
      if (mounted) setState(() => abrindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Abertura de Caixa',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: _verificarCaixaAberto,
          ),
        ],
      ),
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
      bottomNavigationBar:
          AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: Center(
        child: carregando
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(cs.primary),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (caixaAberto)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.error.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cs.error.withValues(alpha: .30),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock_open, color: cs.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'O caixa já está aberto.',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (!caixaAberto) ...[
                        Text(
                          'Valor de abertura',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            prefixText: 'R\$ ',
                            hintText: '0,00',
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: cs.onSurface.withValues(alpha: .12),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatMoney(_controller.text),
                            style: tt.titleMedium?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: (caixaAberto || _controller.text.isEmpty || abrindo)
                              ? null
                              : _confirmar,
                          child: abrindo
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(cs.onPrimary),
                                  ),
                                )
                              : const Text('Confirmar abertura'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
