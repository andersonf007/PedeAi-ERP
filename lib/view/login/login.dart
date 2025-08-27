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
  UsuarioController usuariocontroller = UsuarioController();
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
      if (listFantasias.length == 1) {
        final empresa = listFantasias.first;
        await empresaController.buscarDadosDaEmpresa(empresa['id']);
        return null;
      }
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2419),
        centerTitle: true,
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
        elevation: 0,
      ),
      backgroundColor: Color(0xFF2D2419),
      body: FlutterLogin(
        onLogin: _loginUser,
        onRecoverPassword: _onRecoverPassword,
        onSignup: null,
        onSubmitAnimationCompleted: () async {
          if (listFantasias.length > 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SelecionarEmpresaPage(empresas: listFantasias)));
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (p0) => false);
          }
        },
        messages: LoginMessages(userHint: 'E-mail', passwordHint: 'Senha', forgotPasswordButton: 'Esqueci minha senha', recoverPasswordButton: 'RECUPERAR', goBackButton: 'VOLTAR', recoverPasswordDescription: 'Enviaremos um e-mail para recuperar sua senha', recoverPasswordSuccess: 'E-mail de recuperação enviado'),
        theme: LoginTheme(
          primaryColor: Color(0xFF2D2419),
          accentColor: Colors.orange,
          errorColor: Colors.red,
          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
          textFieldStyle: TextStyle(color: Colors.white, fontSize: 16), // Texto digitado branco
          buttonStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          cardTheme: CardTheme(
            color: Colors.grey[400],
            elevation: 5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          inputTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Label branco
            hintStyle: TextStyle(color: const Color.fromARGB(179, 0, 255, 191)), // Hint branco
            helperStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Mensagens de ajuda branco
            prefixIconColor: Colors.white, // Ícone branco
            suffixIconColor: Colors.white, // Ícone branco
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
