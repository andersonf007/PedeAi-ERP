import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedeai/controller/caixaController.dart';
import 'package:pedeai/utils/caixa_helper.dart';

// seu drawer
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  // ---- Config do painel (estado + defaults)
  bool showCashflow = true;
  bool showDailySummary = true;
  bool showQuickActions = true;

  // subitens (pode esconder individualmente)
  bool sumCounter = true; // Vendas no Balcão
  bool sumDelivery = true; // Vendas por Entrega
  bool sumExpense = true; // Despesas
  bool sumReceipt = true; // Recibos

  bool qaCreateProduct = true; // Criar Produto
  bool qaReports = true; // Relatórios
  bool qaCashSummary = true; // Resumo de caixa
  bool qaReceive = true; // Receber Pagamento
  bool qaPDV = true; // PDV
  static const double _qaHeight = 56.0; // altura fixa p/ todos os quick actions

  final CaixaCotroller _caixaController = CaixaCotroller();

  double receitaMes = 0.00;
  double receitaDiaPdv = 0.00;
  double receitaCanceladaDia = 0.00;
  double despesa = 0.00;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _carregarValoresCaixa();
  }

  Future<void> _carregarValoresCaixa() async {
    try {
      final receitaMesValor = await _caixaController.buscarReceitaDoMes();
      final receitaDiaPdvValor = await _caixaController.buscarReceitaDoDiaDoPdv();
      final receitaCanceladaDiaValor = await _caixaController.buscarReceitaCanceladaDoDia();

      setState(() {
        receitaMes = _formatarValor(receitaMesValor);
        receitaDiaPdv = _formatarValor(receitaDiaPdvValor);
        receitaCanceladaDia = _formatarValor(receitaCanceladaDiaValor);
        despesa = 0.00;
      });
    } catch (e) {
      setState(() {
        receitaMes = 0.00;
        receitaDiaPdv = 0.00;
        receitaCanceladaDia = 0.00;
        despesa = 0.00;
      });
    }
  }

  double _formatarValor(dynamic valor) {
    if (valor == null) return 0.00;
    if (valor is num) return double.parse(valor.toStringAsFixed(2));
    return double.tryParse(valor.toString())?.toDouble() ?? 0.00;
  }

  String _formatarMoeda(double valor) => 'R\$ ${valor.toStringAsFixed(2)}';

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();

    setState(() {
      showCashflow = sp.getBool('dash.showCashflow') ?? true;
      showDailySummary = sp.getBool('dash.showDailySummary') ?? true;
      showQuickActions = sp.getBool('dash.showQuickActions') ?? true;

      sumCounter = sp.getBool('dash.sum.counter') ?? true;
      sumDelivery = sp.getBool('dash.sum.delivery') ?? true;
      sumExpense = sp.getBool('dash.sum.expense') ?? true;
      sumReceipt = sp.getBool('dash.sum.receipt') ?? true;

      qaCreateProduct = sp.getBool('dash.qa.create') ?? true;
      qaReports = sp.getBool('dash.qa.reports') ?? true;
      qaCashSummary = sp.getBool('dash.qa.cashsum') ?? true;
      qaReceive = sp.getBool('dash.qa.receive') ?? true;
      qaPDV = sp.getBool('dash.qa.pdv') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final sp = await SharedPreferences.getInstance();

    await sp.setBool('dash.showCashflow', showCashflow);
    await sp.setBool('dash.showDailySummary', showDailySummary);
    await sp.setBool('dash.showQuickActions', showQuickActions);

    await sp.setBool('dash.sum.counter', sumCounter);
    await sp.setBool('dash.sum.delivery', sumDelivery);
    await sp.setBool('dash.sum.expense', sumExpense);
    await sp.setBool('dash.sum.receipt', sumReceipt);

    await sp.setBool('dash.qa.create', qaCreateProduct);
    await sp.setBool('dash.qa.reports', qaReports);
    await sp.setBool('dash.qa.cashsum', qaCashSummary);
    await sp.setBool('dash.qa.receive', qaReceive);
    await sp.setBool('dash.qa.pdv', qaPDV);
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final saldo = receitaMes - despesa;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Painel', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Configurar painel',
            icon: Icon(Icons.tune, color: cs.onSurface),
            onPressed: _openConfigSheet,
          ),
        ],
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar: AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCashflow) ...[
              const _SectionHeader('Fluxo de Caixa do Mês'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _financeCard(context, label: 'Receita', value: _formatarMoeda(receitaMes), base: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _financeCard(context, label: 'Despesas', value: _formatarMoeda(despesa), base: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _financeCard(context, label: 'Saldo', value: _formatarMoeda(saldo), base: Theme.of(context).colorScheme.primary, fullWidth: true),
              const SizedBox(height: 24),
            ],

            if (showDailySummary) ...[
              const _SectionHeader('Resumo Diário'),
              const SizedBox(height: 12),

              Row(
                children: [
                  if (sumCounter) Expanded(child: _summaryCard(context, 'Vendas no PDV', _formatarMoeda(receitaDiaPdv))),
                  if (sumCounter && sumDelivery) const SizedBox(width: 12),
                  if (sumDelivery) Expanded(child: _summaryCard(context, 'Vendas canceladas', _formatarMoeda(receitaCanceladaDia))),
                ],
              ),
              if (sumCounter || sumDelivery) const SizedBox(height: 12),

              Row(
                children: [
                  if (sumExpense) Expanded(child: _summaryCard(context, 'Despesas', _formatarMoeda(despesa))),
                  if (sumExpense && sumReceipt) const SizedBox(width: 12),
                  if (sumReceipt) Expanded(child: _summaryCard(context, 'Recibos', 'R\$ 1.200,00')),
                ],
              ),
              const SizedBox(height: 24),
            ],

            if (showQuickActions) ...[
              const _SectionHeader('Acesso Rápido'),
              const SizedBox(height: 12),

              Row(
                children: [
                  if (qaCreateProduct) Expanded(child: _quickAction(context, Icons.add, 'Criar Produto', () => Navigator.of(context).pushNamed('/cadastro-produto'))),
                  if (qaCreateProduct && qaReports) const SizedBox(width: 12),
                  if (qaReports) Expanded(child: _quickAction(context, Icons.bar_chart_rounded, 'Relatórios', () {})),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (qaCashSummary) Expanded(child: _quickAction(context, Icons.receipt_long_sharp, 'Resumo de caixa', () {})),
                  if (qaCashSummary && qaReceive) const SizedBox(width: 12),
                  if (qaReceive) Expanded(child: _quickAction(context, Icons.payments_rounded, 'Receber Pagamento', () {})),
                ],
              ),
              const SizedBox(height: 12),
              if (qaPDV) _quickAction(context, Icons.point_of_sale_rounded, 'PDV', () => CaixaHelper.verificarCaixaAbertoENavegar(context, '/pdv'), fullWidth: true),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- widgets de seção ----------
  Widget _financeCard(BuildContext context, {required String label, required String value, required Color base, bool fullWidth = false}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bg = Color.alphaBlend(base.withValues(alpha: 0.14), cs.surface);
    final border = cs.onSurface.withValues(alpha: 0.10);

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.80))),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String title, String value) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bg = Color.alphaBlend(cs.primary.withValues(alpha: 0.06), cs.surface);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.labelMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.80))),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool fullWidth = false}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bg = Color.alphaBlend(cs.primary.withOpacity(0.06), cs.surface);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      // garante MESMA ALTURA para todos
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _qaHeight, maxHeight: _qaHeight),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: cs.onSurface,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // deixa o conteúdo mais “compacto” dentro da altura fixa
            visualDensity: VisualDensity.compact,
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              // texto centralizado, até 2 linhas
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- modal de configuração (rolável, sem overflow) ----------
  Future<void> _openConfigSheet() async {
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SafeArea(
              top: false,
              child: StatefulBuilder(
                builder: (ctx, setMState) {
                  Widget sw(String title, bool value, ValueChanged<bool> onChanged) {
                    return SwitchListTile(
                      title: Text(title, style: Theme.of(ctx).textTheme.bodyLarge),
                      value: value,
                      onChanged: (v) => setMState(() => onChanged(v)),
                      activeColor: cs.primary,
                      contentPadding: EdgeInsets.zero,
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(ctx).padding.bottom + 16),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // handle
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                        Text(
                          'Configurações do Painel',
                          textAlign: TextAlign.center,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),

                        sw('Mostrar “Fluxo de Caixa”', showCashflow, (v) => showCashflow = v),
                        Divider(color: cs.onSurface.withValues(alpha: 0.12)),

                        sw('Mostrar “Resumo Diário”', showDailySummary, (v) => showDailySummary = v),
                        if (showDailySummary) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(children: [sw('• Vendas no Balcão', sumCounter, (v) => sumCounter = v), sw('• Vendas por Entrega', sumDelivery, (v) => sumDelivery = v), sw('• Despesas', sumExpense, (v) => sumExpense = v), sw('• Recibos', sumReceipt, (v) => sumReceipt = v)]),
                          ),
                        ],
                        Divider(color: cs.onSurface.withValues(alpha: 0.12)),

                        sw('Mostrar “Acesso Rápido”', showQuickActions, (v) => showQuickActions = v),
                        if (showQuickActions) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(children: [sw('• Criar Produto', qaCreateProduct, (v) => qaCreateProduct = v), sw('• Relatórios', qaReports, (v) => qaReports = v), sw('• Resumo de caixa', qaCashSummary, (v) => qaCashSummary = v), sw('• Receber Pagamento', qaReceive, (v) => qaReceive = v), sw('• PDV', qaPDV, (v) => qaPDV = v)]),
                          ),
                        ],
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _savePrefs();
                                  if (mounted) {
                                    setState(() {});
                                    Navigator.pop(ctx);
                                  }
                                },
                                child: const Text('Salvar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ------------ componentes auxiliares ------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cs.onSurface.withValues(alpha: 0.12), thickness: 1)),
      ],
    );
  }
}

/// Bottom nav do projeto, estilizado pelo tema (reutilizável).
class PedeAiBottomNav extends StatelessWidget {
  const PedeAiBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: 64,
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withValues(alpha: 0.12),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Painel'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Vendas'),
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produtos'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Estoque'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Usuários'),
      ],
    );
  }
}
