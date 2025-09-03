import 'dart:convert';

import 'package:flutter_login/flutter_login.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/model/usuario.dart';
import 'package:pedeai/script/scriptUsuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioController {
  final AuthService _authService = AuthService();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();
  ScriptUsuario script = ScriptUsuario();
  final DatabaseService _databaseService = DatabaseService();

  Future<String?> buscarLogin(LoginData data) async {
    try {
      prefs = await SharedPreferences.getInstance(); // Adicione esta linha
      final response = await _authService.signIn(
        email: data.name,
        password: data.password,
      );

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

  Future<List<Usuario>> listarUsuario() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await empresaController
          .getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      String query = script.listarUsuarios(empresa.id);
      // Executar query
      final response = await _databaseService.executeSqlListar(sql: query);

      if (response.isEmpty) {
        return [];
      }

      // Converter resposta para lista de usuários
      List<Usuario> usuarios = response.map<Usuario>((item) {
        return Usuario.fromJson(item);
      }).toList();

      return usuarios;
    } catch (e) {
      return [];
    }
  }

  Future<String?> verificarEmailSeExiste(String email) async {
    try {
      return _authService.emailJaExiste(email);
    } catch (e) {
      throw Exception('Erro ao verificar email: ${e.toString()}');
    }
  }

  Future<AuthResponse> cadastrarUsuario(String email, String senha) async {
    try {
      return await _authService.signUp(email: email, password: senha);
    } catch (e) {
      throw Exception('Erro ao cadastrar usuário: ${e.toString()}');
    }
  }

  Future<void> inserirUsuario(Map<String, dynamic> dados) async {
    try {
      await _databaseService.executeSql(
        script.scriptInsertUsuario(dados),
        schema: 'public',
      );
    } catch (e) {
      throw Exception('Erro ao salvar usuário: ${e.toString()}');
    }
  }

  Future<void> insertUsuarioDaEmpresa(Map<String, dynamic> dados) async {
    try {
      Empresa? empresa = await empresaController
          .getEmpresaFromSharedPreferences();
      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }
      dados['id_empresa'] = empresa!.id;
      await _databaseService.executeSql(
        script.scriptInsertUsuarioDaEmpresa(dados),
        schema: 'public',
      );
    } catch (e) {
      throw Exception('Erro ao salvar usuário: ${e.toString()}');
    }
  }

  Future<void> atualizarUsuario(Map<String, dynamic> dados) async {
    try {
      await _databaseService.executeSql(
        script.scriptAtualizarUsuario(dados),
        schema: 'public',
      );
    } catch (e) {
      throw Exception('Erro ao salvar usuário: ${e.toString()}');
    }
  }

  //NAO ESTA SALVANDO EM NENHUM LUGAR O USUARIO ATEA AGORA
  Future<Usuario?> getUsuarioFromSharedPreferences() async {
    try {
      prefs = await SharedPreferences.getInstance();
      String? usuarioJson = prefs.getString('usuario');

      if (usuarioJson != null) {
        Map<String, dynamic> usuarioMap = json.decode(usuarioJson);
        return Usuario.fromJson(usuarioMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUidUsuarioFromSharedPreferences() async {
    try {
      prefs = await SharedPreferences.getInstance();
      return prefs.getString('uid');
    } catch (e) {
      return null;
    }
  }
}
