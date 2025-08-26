import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/view/login/selecionarEmpresa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedeai/theme/app_theme.dart'; // usamos os adapters aqui

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Usuariocontroller _userController = Usuariocontroller();
  final EmpresaController _empresaController = EmpresaController();
  SharedPreferences? _prefs;
  final List<Map<String, dynamic>> _empresas = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) => _prefs = sp);
  }

  Future<String?> _onRecoverPassword(String email) async => null;

  Future<String?> _onLogin(LoginData data) async {
    _empresas.clear();
    _prefs ??= await SharedPreferences.getInstance();

    final erro = await _userController.buscarLogin(data);
    if (erro == null) {
      final uid = _prefs!.getString('uid') ?? '';
      final ids = await _empresaController.buscarIdDasEmpresasDoUsuario(uid);
      final fantasias =
          await _empresaController.buscarNomeFantasiaDasEmpresasDoUsuario(ids);
      _empresas.addAll(fantasias);

      if (_empresas.length == 1) {
        await _empresaController.buscarDadosDaEmpresa(_empresas.first['id']);
      }
    }
    return erro; // null == ok
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    // fundos
    const base = 'images';
    final bg = isDark
        ? '$base/background_login_dark.png'
        : '$base/background_login_white.png';
    const logo = '$base/logo.png';

    // no claro, sem scrim; no escuro, contraste leve
    final scrim = Color.fromRGBO(0, 0, 0, isDark ? 0.32 : 0.00);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(bg, fit: BoxFit.cover),
          Container(color: scrim),

          FlutterLogin(
            // só a LOGO anima
            logo: const AssetImage(logo),
            // título estático dentro do card
            headerWidget: const _CardHeaderTitle(),

            onLogin: _onLogin,
            onRecoverPassword: _onRecoverPassword,
            hideForgotPasswordButton: false,

            onSubmitAnimationCompleted: () {
              if (_empresas.length > 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        SelecionarEmpresaPage(empresas: _empresas),
                  ),
                );
              } else {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/home', (route) => false);
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

            // 🔧 use os ADAPTERS do seu tema (tipos corretos)
            theme: LoginTheme(
              pageColorDark: Colors.transparent,
              pageColorLight: Colors.transparent,
              primaryColor: Colors.transparent,
              errorColor: cs.error,
              accentColor: cs.onSurface.withValues(alpha: 0.7),

              // usa os adapters
              cardTheme: LoginThemeAdapters.card(context),
              inputTheme: LoginThemeAdapters.input(context),

              textFieldStyle: TextStyle(color: cs.onSurface),
              bodyStyle: TextStyle(color: cs.onSurface),
              footerTextStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.70)),
              switchAuthTextColor: cs.primary,
              buttonTheme: LoginButtonTheme(
                backgroundColor: cs.primary,
                highlightColor: cs.primaryContainer,
                splashColor: cs.primary,
                elevation: 0,
                highlightElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeaderTitle extends StatelessWidget {
  const _CardHeaderTitle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Text(
          'Login',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
