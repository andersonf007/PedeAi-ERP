import 'package:flutter_login/flutter_login.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/script/script.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Usuariocontroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Script script = Script();
  late SharedPreferences prefs;

  Future<String?> buscarLogin(LoginData data) async {
    try {
      prefs = await SharedPreferences.getInstance(); // Adicione esta linha
      final response = await _authService.signIn(email: data.name, password: data.password);

      if (response.user != null) {
        // Verificar se email foi confirmado
        if (!_authService.isEmailConfirmed) {
          return 'Por favor, confirme seu email antes de fazer login';
        }
        await prefs.setString('uid', response.user!.id);
        return null; // Sucesso
      } else {
        return 'Credenciais inválidas';
      }
    } catch (e) {
      return 'Erro ao fazer login: ${e.toString()}';
    }
  }
}
