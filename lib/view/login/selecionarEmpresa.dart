import 'package:flutter/material.dart';
import 'package:pedeai/controller/empresaController.dart';

class SelecionarEmpresaPage extends StatefulWidget {
  final List<Map<String, dynamic>> empresas;

  const SelecionarEmpresaPage({super.key, required this.empresas});

  @override
  State<SelecionarEmpresaPage> createState() => _SelecionarEmpresaPageState();
}

class _SelecionarEmpresaPageState extends State<SelecionarEmpresaPage> {
  Map<String, dynamic>? _empresaSelecionada;

  @override
  Widget build(BuildContext context) {
    final empresaController = EmpresaController();

    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        centerTitle: true,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, color: Colors.orange, size: 30),
            SizedBox(width: 8),
            Text(
              'PedeAi',
              style: TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Text('ERP', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.symmetric(horizontal: 24),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione a empresa',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              DropdownButton<Map<String, dynamic>>(
                isExpanded: true,
                value: _empresaSelecionada,
                dropdownColor: Color(0xFF2D2419),
                hint: Text('Selecione uma empresa', style: TextStyle(color: Colors.white70)),
                items: widget.empresas.map((empresa) {
                  return DropdownMenuItem(
                    value: empresa,
                    child: Text(empresa['fantasia'] ?? '', style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _empresaSelecionada = value;
                  });
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _empresaSelecionada == null
                      ? null
                      : () async {
                          try {
                            await empresaController.buscarDadosDaEmpresa(_empresaSelecionada!['id']);
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar empresa: $e'), backgroundColor: Colors.red));
                            }
                          }
                        },
                  child: Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
