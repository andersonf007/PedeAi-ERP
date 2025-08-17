import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/view/login/selecionarEmpresa.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  TextEditingController textSenha = TextEditingController();
  TextEditingController textUsuario = TextEditingController();
  Usuariocontroller usuariocontroller = Usuariocontroller();
  EmpresaController empresaController = EmpresaController();
  List<Map<String, dynamic>> listFantasias = [];

  late SharedPreferences prefs;
  String versaoApi = '1.0.0';
 @override
void initState() {
  super.initState();
  SharedPreferences.getInstance().then((instance) {
    prefs = instance;
  });
}
  Future<String?> _onRecoverPassword(String name) async {
    return null;
  }

  Future<String?> _loginUser(LoginData data) async {
    listFantasias.clear();
    String? resultado = await usuariocontroller.buscarLogin(data);
    if (resultado == null) {
      String uid = prefs.getString('uid') ?? '';
      List<int> listIds = await empresaController.buscarIdDasEmpresasDoUsuario(uid);
    
         listFantasias = await empresaController.buscarNomeFantasiaDasEmpresasDoUsuario(listIds);
      // Se só tem uma empresa, já busca os dados e vai para home
      if (listFantasias.length == 1) {
        final empresa = listFantasias.first;
        await empresaController.buscarDadosDaEmpresa(empresa['id']);
        return null;
      }
    }
    return resultado;
  }

  Future<String?> _signupUser(SignupData data) async {
    // Retorne null se o cadastro for bem-sucedido, ou uma string de erro
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        title: 'Pede Ai ERP',
        onLogin: _loginUser,
        onRecoverPassword: _onRecoverPassword,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () async {
          // Se houver mais de uma empresa, navega para SelecionarEmpresaPage
          if (listFantasias.length > 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SelecionarEmpresaPage(empresas: listFantasias)));
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (p0) => false);
          }
        },
        messages: LoginMessages(
          userHint: 'E-mail',
          passwordHint: 'Senha',
          confirmPasswordHint: 'Confirmar Senha',
          loginButton: 'ENTRAR',
          signupButton: 'CADASTRAR',
          forgotPasswordButton: 'Esqueci minha senha',
          recoverPasswordButton: 'RECUPERAR',
          goBackButton: 'VOLTAR',
          confirmPasswordError: 'As senhas não coincidem',
          recoverPasswordDescription: 'Enviaremos um e-mail para recuperar sua senha',
          recoverPasswordSuccess: 'E-mail de recuperação enviado',
        ),
        theme: LoginTheme(
          primaryColor: Colors.teal,
          accentColor: Colors.yellow,
          errorColor: Colors.red,
          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
          bodyStyle: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
          textFieldStyle: TextStyle(color: Colors.black, fontSize: 16),
          buttonStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 5,
            margin: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        /*additionalSignupFields: [
          UserFormField(
            keyName: 'name',
            displayName: 'Nome Completo',
            fieldValidator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu nome completo';
              }
              if (value.length < 2) {
                return 'Nome deve ter pelo menos 2 caracteres';
              }
              return null;
            },
            icon: Icon(Icons.person),
          ),
          // Você pode adicionar mais campos se necessário
          UserFormField(
            keyName: 'phone',
            displayName: 'Telefone',
            fieldValidator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu telefone';
              }
              // Validação simples de telefone
              if (!RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$').hasMatch(value)) {
                return 'Formato: (11) 99999-9999';
              }
              return null;
            },
            icon: Icon(Icons.phone),
          ),
        ],*/
      ),
    );
  }
}
