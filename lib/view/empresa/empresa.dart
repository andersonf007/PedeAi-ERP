import 'package:flutter/material.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';
import 'package:pedeai/view/empresa/empresaEditarDialog.dart';

/// Helper para evitar `withOpacity` deprecado (Material 3).
extension _Cx on Color {
  Color opa(double a) => withValues(alpha: a);
}

class EmpresaPage extends StatefulWidget {
  const EmpresaPage({Key? key}) : super(key: key);

  @override
  State<EmpresaPage> createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  final EmpresaController _empresaController = EmpresaController();
  Empresa? _empresa;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarEmpresa();
  }

  Future<void> _carregarEmpresa() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      // 1) tenta do SharedPreferences
      Empresa? emp = await _empresaController.getEmpresaFromSharedPreferences();

      // 2) se não tiver, busca no backend (ajuste o id se necessário)
      if (emp == null) {
        final dados = await _empresaController.buscarDadosDaEmpresa(1);
        emp = Empresa.fromJson(dados);
      }

      setState(() {
        _empresa = emp;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar dados da empresa: $e';
        _carregando = false;
      });
    }
  }

  // ---------- helpers ----------
  String _txt(String? v) => (v != null && v.trim().isNotEmpty) ? v.trim() : '—';

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
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'Dados da Empresa',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Sem ações (lápis removido)
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar:
          AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _erro!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                )
              : _empresa == null
                  ? Center(
                      child: Text(
                        'Nenhuma empresa encontrada.',
                        style: TextStyle(color: cs.onSurface.opa(.7)),
                      ),
                    )
                  : Column(
                      children: [
                        // Conteúdo rolável
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _carregarEmpresa,
                            child: ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              children: [
                                // ---------- Cabeçalho ----------
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: cs.onSurface.opa(.10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Nome + chip schema (se houver)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _txt(_empresa!.fantasia),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  tt.titleLarge?.copyWith(
                                                color: cs.onSurface,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (_txt(_empresa!.schema) != '—')
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: cs.primary,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                _empresa!.schema!,
                                                style: TextStyle(
                                                  color: cs.onPrimary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // CNPJ
                                      Row(
                                        children: [
                                          Icon(Icons.badge_outlined,
                                              size: 18,
                                              color: cs.onSurface.opa(.7)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'CNPJ: ',
                                            style: tt.bodyMedium?.copyWith(
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _txt(_empresa!.cnpj),
                                              style:
                                                  tt.bodyMedium?.copyWith(
                                                color: cs.onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Email
                                      Row(
                                        children: [
                                          Icon(Icons.mail_outline,
                                              size: 18,
                                              color: cs.onSurface.opa(.7)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _txt(_empresa!.email),
                                            style:
                                                tt.bodyMedium?.copyWith(
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Telefone
                                      Row(
                                        children: [
                                          Icon(Icons.call_outlined,
                                              size: 18,
                                              color: cs.onSurface.opa(.7)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _txt(_empresa!.telefone),
                                            style:
                                                tt.bodyMedium?.copyWith(
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------- Endereço ----------
                                Text(
                                  'Endereço',
                                  style: tt.titleSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: cs.onSurface.opa(.10)),
                                  ),
                                  child: Column(
                                    children: [
                                      _InfoLine(
                                        label: 'Logradouro',
                                        value: _txt(_empresa!.logradouro),
                                      ),
                                      _InfoLine(
                                        label: 'Número',
                                        value: _txt(_empresa!.numero),
                                      ),
                                      _InfoLine(
                                        label: 'Bairro',
                                        value: _txt(_empresa!.bairro),
                                      ),
                                      _InfoLine(
                                        label: 'Município',
                                        value: _txt(_empresa!.municipio),
                                      ),
                                      _InfoLine(
                                        label: 'UF',
                                        value: _txt(_empresa!.uf),
                                      ),
                                      _InfoLine(
                                        label: 'CEP',
                                        value: _txt(_empresa!.cep),
                                        last: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ---------- CTA fixo no rodapé (padrão Produtos) ----------
                        SafeArea(
                          top: false,
                          minimum:
                              const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _empresa == null
                                  ? null
                                  : () async {
                                      final alterado = await showDialog<bool>(
                                        context: context,
                                        builder: (context) =>
                                            EmpresaEditarDialog(
                                                empresa: _empresa!),
                                      );
                                      if (alterado == true) {
                                        await _carregarEmpresa();
                                      }
                                    },
                              child: const Text('Editar dados'),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

// ---------- widgets auxiliares ----------

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.opa(.85),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (!last) Divider(height: 14, color: cs.onSurface.opa(.06)),
      ],
    );
  }
}
