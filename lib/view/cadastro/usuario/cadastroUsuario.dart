import 'package:flutter/material.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/usuario.dart';
import 'package:pedeai/utils/app_notify.dart';
import 'package:pedeai/theme/color_tokens.dart'; // laranja do design
import 'package:pedeai/app_nav_bar.dart'; // ⬅ bottom nav

class CadastroUsuarioPage extends StatefulWidget {
  final Usuario? usuario;
  const CadastroUsuarioPage({Key? key, this.usuario}) : super(key: key);

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final UsuarioController _usuarioController = UsuarioController();

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  String? _uidUsuario;
  bool _isEdicao = false;
  bool _salvando = false;

  // monitor de alterações
  late String _initialNome;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();

    // monitorar mudanças do nome (no modo edição)
    _nomeCtrl.addListener(_recalcDirty);

    // Se veio pelo construtor
    if (widget.usuario != null) {
      _hydrateFrom(widget.usuario!);
    } else {
      // baseline em modo cadastro
      _initialNome = _nomeCtrl.text.trim();
      _dirty = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se veio por pushNamed(arguments)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (!_isEdicao && args is Usuario) {
      _hydrateFrom(args);
    }
  }

  void _hydrateFrom(Usuario u) {
    _isEdicao = true;
    _uidUsuario = u.uid;
    _nomeCtrl.text = u.nome ?? '';
    _emailCtrl.text = u.email ?? '';

    // baseline para comparação
    _initialNome = _nomeCtrl.text.trim();
    _dirty = false;
    setState(() {});
  }

  void _recalcDirty() {
    if (!_isEdicao) return; // só monitoramos no modo edição
    final nowNome = _nomeCtrl.text.trim();
    final changed = nowNome != _initialNome;
    if (changed != _dirty) {
      setState(() => _dirty = changed);
    }
  }

  @override
  void dispose() {
    _nomeCtrl.removeListener(_recalcDirty);
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvarUsuario() async {
    if (_salvando) return;

    final nome = _nomeCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text.trim();

    if (nome.isEmpty) {
      AppNotify.error(context, 'Informe o nome.');
      return;
    }
    if (email.isEmpty) {
      AppNotify.error(context, 'Informe o e-mail.');
      return;
    }
    if (!_isEdicao && senha.isEmpty) {
      AppNotify.error(context, 'Informe a senha.');
      return;
    }

    setState(() => _salvando = true);

    try {
      if (_isEdicao) {
        final uid = _uidUsuario ?? '';
        if (uid.isEmpty) {
          AppNotify.error(context, 'UID do usuário não encontrado.');
          setState(() => _salvando = false);
          return;
        }
        // toggle de ativo fica só na listagem
        await _usuarioController.atualizarUsuario({
          'uid': uid,
          'nome': nome,
        });
        AppNotify.success(context, 'Usuário alterado com sucesso!');
      } else {
        // cadastro novo
        String uidUsuarioCadastrado = '';
        final emailExists = await _usuarioController.verificarEmailSeExiste(email);

        if (emailExists != null) {
          uidUsuarioCadastrado = emailExists;
        } else {
          final response = await _usuarioController.cadastrarUsuario(email, senha);
          if (response.user == null) {
            AppNotify.error(context, 'Erro ao cadastrar usuário.');
            setState(() => _salvando = false);
            return;
          }
          uidUsuarioCadastrado = response.user!.id;

          await _usuarioController.inserirUsuario({
            'nome': nome,
            'email': email,
            'uid': uidUsuarioCadastrado,
            'is_admin': true,
          });
        }

        await _usuarioController.insertUsuarioDaEmpresa({'uid': uidUsuarioCadastrado});
        AppNotify.success(context, 'Usuário cadastrado com sucesso!');
      }

      if (!mounted) return;
      Navigator.pop(context, true); // sinaliza recarregar listagem
    } catch (e) {
      AppNotify.error(context, 'Erro: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orange = cs.primary; // laranja do design

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        centerTitle: true,
        elevation: 0,
        title: Text(
          _isEdicao ? 'Editar Usuário' : 'Cadastrar Usuário',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: cs.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome
              Text('Nome',
                  style:
                      TextStyle(color: cs.onSurface.withOpacity(0.9), fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _nomeCtrl,
                decoration: InputDecoration(
                  hintText: 'Nome completo',
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: TextStyle(color: cs.onSurface),
              ),
              const SizedBox(height: 16),

              // E-mail
              Text('E-mail',
                  style:
                      TextStyle(color: cs.onSurface.withOpacity(0.9), fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                enabled: !_isEdicao,
                decoration: InputDecoration(
                  hintText: 'exemplo@dominio.com',
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: cs.onSurface),
              ),
              if (!_isEdicao) const SizedBox(height: 16),

              // Senha (apenas no cadastro)
              if (!_isEdicao) ...[
                Text('Senha',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.9), fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 6 caracteres',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  style: TextStyle(color: cs.onSurface),
                ),
              ],

              const SizedBox(height: 24),

              // Botão dinâmico
              SizedBox(
                width: double.infinity,
                height: 46,
                child: _isEdicao
                    ? (_dirty
                        // EDIÇÃO + COM MUDANÇAS → Salvar Alterações (primary)
                        ? ElevatedButton(
                            onPressed: _salvando ? null : _salvarUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            child: _salvando
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(cs.onPrimary),
                                    ),
                                  )
                                : const Text('Salvar Alterações'),
                          )
                        // EDIÇÃO + SEM MUDANÇAS → Cancelar (outlined LARANJA)
                        : OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: orange, width: 1.5),
                              foregroundColor: orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overlayColor: orange.withOpacity(0.08),
                            ),
                            child: const Text('Cancelar'),
                          ))
                    // CADASTRO → Cadastrar (primary)
                    : ElevatedButton(
                        onPressed: _salvando ? null : _salvarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: _salvando
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(cs.onPrimary),
                                ),
                              )
                            : const Text('Cadastrar'),
                      ),
              ),
            ],
          ),
        ),
      ),

      // ⬇⬇ bottom navigation no padrão do app
      bottomNavigationBar: AppNavBar(
        currentRoute: ModalRoute.of(context)?.settings.name,
      ),
    );
  }
}
