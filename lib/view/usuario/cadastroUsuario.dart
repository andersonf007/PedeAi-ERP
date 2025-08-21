import 'package:flutter/material.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/usuario.dart';
import 'package:pedeai/script/scriptUsuario.dart';
import 'package:pedeai/controller/databaseService.dart';

class CadastroUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  CadastroUsuarioPage({Key? key, this.usuario}) : super(key: key);

  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final Usuariocontroller usuariocontroller = Usuariocontroller();
  final DatabaseService databaseService = DatabaseService();
  final ScriptUsuario scriptUsuario = ScriptUsuario();

  final TextEditingController _nomeUsuarioController = TextEditingController();
  final TextEditingController _emailUsuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _ativo = true;
  String? _uidUsuario;
  bool _isEdicao = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.usuario != null) {
      _isEdicao = true;
      _uidUsuario = widget.usuario!.uid;
      _nomeUsuarioController.text = widget.usuario!.nome ?? '';
      _emailUsuarioController.text = widget.usuario!.email ?? '';
      _ativo = widget.usuario!.ativo ?? true;
    }
  }

  void _mostrarMensagem(String msg, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: cor));
  }

  Future<void> _salvarUsuario() async {
    try {
      String uidUsuarioCadastrado = '';
      if (!_isEdicao) {
        final emailExists = await usuariocontroller.verificarEmailSeExiste(_emailUsuarioController.text);
        if (emailExists != null) {
          uidUsuarioCadastrado = emailExists;
        } else {
          final response = await usuariocontroller.cadastrarUsuario(_emailUsuarioController.text, _senhaController.text);
          if (response.user == null) {
            _mostrarMensagem('Erro ao cadastrar usuário', Colors.red);
            return;
          }
          uidUsuarioCadastrado = response.user!.id;
        }

        if (emailExists == null) {
          await usuariocontroller.inserirUsuario({'nome': _nomeUsuarioController.text.trim(), 'email': _emailUsuarioController.text.trim(), 'uid': uidUsuarioCadastrado, 'is_admin': true});
        }
        await usuariocontroller.insertUsuarioDaEmpresa({'uid': uidUsuarioCadastrado});

        _mostrarMensagem('Usuário cadastrado com sucesso!', Colors.green);
        Navigator.pop(context);
      } else {
        // Atualiza os dados do usuário (exceto email)
        await _alterarUsuario();
        _mostrarMensagem('Usuário alterado com sucesso!', Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      _mostrarMensagem('Erro: $e', Colors.red);
    }
  }

  Future<void> _alterarUsuario() async {
    await usuariocontroller.atualizarUsuario({'uid': _uidUsuario, 'nome': _nomeUsuarioController.text.trim(), 'ativo': _ativo});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2419),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        centerTitle: true,
        title: Text(
          _isEdicao ? 'Editar Usuário' : 'Cadastrar Usuário',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF4A3429), borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeUsuarioController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF2D2419),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailUsuarioController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF2D2419),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: Colors.white),
                enabled: !_isEdicao,
              ),
              if (!_isEdicao) SizedBox(height: 16),
              if (!_isEdicao)
                TextField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF2D2419),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _ativo,
                    onChanged: (value) {
                      setState(() {
                        _ativo = value ?? true;
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                  Text('Usuário Ativo', style: TextStyle(color: Colors.white)),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarUsuario,
                  child: Text(_isEdicao ? 'Salvar Alterações' : 'Cadastrar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
