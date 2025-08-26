import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/view/login/selecionarEmpresa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedeai/theme/color_tokens.dart'; // BrandColors.warning700

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final Usuariocontroller usuariocontroller = Usuariocontroller();
  final EmpresaController empresaController = EmpresaController();

  SharedPreferences? _prefs;
  final List<Map<String, dynamic>> listFantasias = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) => _prefs = sp);
  }

  Future<String?> _onRecoverPassword(String email) async {
    // implemente seu fluxo real aqui quando tiver o endpoint
    return null;
  }

  Future<String?> _loginUser(LoginData data) async {
    listFantasias.clear();

    _prefs ??= await SharedPreferences.getInstance();
    final resultado = await usuariocontroller.buscarLogin(data);

    if (resultado == null) {
      final uid = _prefs!.getString('uid') ?? '';
      final listIds = await empresaController.buscarIdDasEmpresasDoUsuario(uid);
      final fantasias = await empresaController
          .buscarNomeFantasiaDasEmpresasDoUsuario(listIds);
      listFantasias.addAll(fantasias);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Assets
    const _base = 'images';
    final bgPath = isDark
        ? '$_base/background_login_dark.png'
        : '$_base/background_login_white.png';
    final logoPath = isDark ? '$_base/logo.png' : '$_base/logo.png';

    return Scaffold(
      backgroundColor: const Color(0xFF2D2419),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo com pattern
          Image.asset(bgPath, fit: BoxFit.cover),
          // Scrim para contraste
          Container(color: Colors.black.withOpacity(0.35)),

          // Formulário
          FlutterLogin(
            // LOGO FORA DO CARD, no topo
            logo: AssetImage(logoPath),

            // NÃO use "title". O título vai dentro do card:
            headerWidget: const _CardTitle(),

            onLogin: _loginUser,
            onRecoverPassword: _onRecoverPassword,

            onSubmitAnimationCompleted: () async {
              if (listFantasias.length > 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        SelecionarEmpresaPage(empresas: listFantasias),
                  ),
                );
              } else {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (p0) => false);
              }
            },

            messages: LoginMessages(
              userHint: 'E-mail',
              passwordHint: 'Senha',
              loginButton: 'Entrar',
              forgotPasswordButton: 'Esqueceu sua senha?',
              recoverPasswordButton: 'RECUPERAR',
              goBackButton: 'VOLTAR',
              recoverPasswordDescription:
                  'Enviaremos um e-mail para recuperar sua senha',
              recoverPasswordSuccess: 'E-mail de recuperação enviado',
            ),

            // Tema alinhado ao design
            theme: LoginTheme(
              pageColorDark: Colors.transparent,
              pageColorLight: Colors.transparent,
              primaryColor: Colors.transparent,

              textFieldStyle: const TextStyle(color: Colors.white),
              bodyStyle: const TextStyle(color: Colors.white),
              footerTextStyle: const TextStyle(color: Colors.white70),

              // cor de link ("Crie sua conta")
              switchAuthTextColor: BrandColors.warning700,

              // Card translúcido
              cardTheme: CardTheme(
                color: Colors.black.withOpacity(0.55),
                elevation: 0,
                // margem superior maior para não brigar com a logo
                margin: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              // Campos
              inputTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF4A3B31),
                hintStyle: const TextStyle(color: Colors.white70),
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIconColor: Colors.white70,
                suffixIconColor: Colors.white70,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white10),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: BrandColors.primary700,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Botão laranja
              buttonTheme: LoginButtonTheme(
                backgroundColor: BrandColors.primary500,
                highlightColor: BrandColors.primary700,
                splashColor: BrandColors.primary900,
                elevation: 0,
                highlightElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              accentColor: Colors.white70,
              errorColor: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Título dentro do card
class _CardTitle extends StatelessWidget {
  const _CardTitle();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
