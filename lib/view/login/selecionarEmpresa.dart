import 'package:flutter/material.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/utils/app_notify.dart';

class SelecionarEmpresaPage extends StatefulWidget {
  final List<Map<String, dynamic>> empresas;

  const SelecionarEmpresaPage({super.key, required this.empresas});

  @override
  State<SelecionarEmpresaPage> createState() => _SelecionarEmpresaPageState();
}

class _SelecionarEmpresaPageState extends State<SelecionarEmpresaPage> {
  final _empresaController = EmpresaController();

  Map<String, dynamic>? _empresaSelecionada;
  bool _carregando = false;

  Future<void> _continuar() async {
    if (_empresaSelecionada == null || _carregando) return;

    setState(() => _carregando = true);
    try {
      await _empresaController.buscarDadosDaEmpresa(_empresaSelecionada!['id']);
      if (!mounted) return;
      AppNotify.success(context, 'Empresa selecionada: ${_empresaSelecionada!['fantasia']}');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      AppNotify.error(context, 'Erro ao carregar empresa: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: cs.onBackground),
        title: Text(
          'Selecionar Empresa',
          style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecione a empresa',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdown no padrão M3 com InputDecoration
                DropdownButtonFormField<Map<String, dynamic>>(
                  isExpanded: true,
                  value: _empresaSelecionada,
                  dropdownColor: cs.surface,
                  iconEnabledColor: cs.onSurface,
                  decoration: InputDecoration(
                    hintText: 'Escolha uma empresa...',
                    hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: widget.empresas.map((empresa) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: empresa,
                      child: Text(
                        empresa['fantasia'] ?? '',
                        style: TextStyle(color: cs.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _empresaSelecionada = value),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: (_empresaSelecionada == null || _carregando) ? null : _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: _carregando
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(cs.onPrimary),
                            ),
                          )
                        : const Text('Continuar'),
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
