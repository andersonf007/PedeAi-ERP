import 'package:flutter/material.dart';
import 'package:pedeai/controller/clienteController.dart';
import 'package:pedeai/model/cliente.dart';
import 'package:pedeai/view/home/drawer.dart';
import 'package:pedeai/app_nav_bar.dart';

class ListClientesPage extends StatefulWidget {
  const ListClientesPage({super.key});

  @override
  State<ListClientesPage> createState() => _ListClientesPageState();
}

class _ListClientesPageState extends State<ListClientesPage> {
  final ClienteController _controller = ClienteController();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String _error = '';
  List<Cliente> _clientes = [];
  List<Cliente> _filtrados = [];
  String _tipoContribuinte = 'N';

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final dados = await _controller.listarClientes();
      if (!mounted) return;
      setState(() {
        _clientes = List.from(dados);
        // Se não há busca, mostra todos; se há busca, aplica filtro
        if (_searchCtrl.text.trim().isEmpty) {
          _filtrados = List.from(dados);
        } else {
          _filtrados = _clientes.where((f) {
            final query = _searchCtrl.text.toLowerCase();
            return f.nome!.toLowerCase().contains(query) || (f.nomeSocial?.toLowerCase() ?? '').contains(query) || (f.cpf ?? '').contains(query);
          }).toList();
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar clientes: $e';
        _loading = false;
        _clientes = [];
        _filtrados = [];
      });
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filtrados = List.from(_clientes);
      });
      return;
    }
    final filtrados = _clientes.where((f) {
      return f.nome!.toLowerCase().contains(query) || (f.nomeSocial?.toLowerCase() ?? '').contains(query) || (f.cpf ?? '').contains(query);
    }).toList();
    setState(() {
      _filtrados = filtrados;
    });
  }

  void _navigateToCadastro([int? clienteId]) async {
    final result = await Navigator.pushNamed(context, '/cadastroCliente', arguments: clienteId);
    if (result == true) {
      setState(() => _loading = true);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: cs.onSurface),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Clientes',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
      bottomNavigationBar: AppNavBar(currentRoute: ModalRoute.of(context)?.settings.name),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar por Nome, nome social ou cpf',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          Expanded(child: _buildContent(cs)),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _navigateToCadastro(),
                child: const Text('Cadastrar Novo Cliente'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: Text(_error, style: TextStyle(color: cs.error)),
      );
    }
    if (_filtrados.isEmpty) {
      final isSearching = _searchCtrl.text.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            isSearching ? 'Nenhum cliente encontrado para "${_searchCtrl.text}"' : 'Nenhum cliente cadastrado, cadastre algum',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemBuilder: (context, index) {
        final cliente = _filtrados[index];
        if (cliente.nomeSocial!.trim().isEmpty && (cliente.cpf == null || cliente.cpf!.trim().isEmpty)) {
          // Não renderiza card vazio
          return const SizedBox.shrink();
        }
        return Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToCadastro(cliente.id),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  // Ícone de fornecedor
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.business, color: cs.onPrimaryContainer, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Informações do fornecedor
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nome!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Nome fantasia se disponível
                        if (cliente.nomeSocial != null && cliente.nomeSocial!.trim().isNotEmpty) ...[
                          Text(
                            cliente.nomeSocial!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.8), fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],

                        // CNPJ ou indicação de sem CNPJ
                        Row(
                          children: [
                            Icon(Icons.numbers, size: 14, color: cs.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text((cliente.cpf != null && cliente.cpf!.trim().isNotEmpty) ? cliente.cpf! : 'Sem CPF', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                          ],
                        ),

                        // Telefone se disponível
                        if (cliente.telefone != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: cs.onSurface.withOpacity(0.6)),
                              const SizedBox(width: 4),
                              Text(cliente.telefone?.numero ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Ícone de seta
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: cs.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
