import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/caixa.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/model/forma_pagamento.dart';
import 'package:pedeai/script/scriptCaixa.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaixaCotrollerException implements Exception {
  String message;
  CaixaCotrollerException(this.message);
}

class CaixaCotroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  late SharedPreferences prefs;
  final ScriptCaixa _scriptCaixa = ScriptCaixa();
  final EmpresaController empresaController = EmpresaController();
  final UsuarioController usuarioController = UsuarioController();

  Future<void> _salvarIdCaixaSharedPreferences(int idCaixa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_caixa', idCaixa);
  }

  Future<int> abrirCaixa(double valor, String periodo) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();

      String sql = _scriptCaixa.inserirCaixa(empresa!.schema, {'aberto': true, 'data_abertura': DateTime.now(), 'id_usuario_abertura': "'$uidUsuario'", 'valor_abertura': valor, 'periodo_abertura': "'$periodo'"});
      final resultado = await _databaseService.executeSql(sql, schema: empresa.schema);
      int idCaixa = resultado.first['id'] as int;
      if (idCaixa != -1) {
        await _salvarIdCaixaSharedPreferences(idCaixa);
      }
      return idCaixa;
    } catch (e) {
      throw CaixaCotrollerException('Erro ao abrir caixa: $e');
    }
  }

  Future<int> buscarCaixaAberto() async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String sql = _scriptCaixa.buscarCaixaAberto(empresa!.schema);
      final resultado = await _databaseService.executeSql(sql, schema: empresa.schema);
      int? idCaixa = resultado.isNotEmpty ? resultado.first['id'] as int? : null;
      if (idCaixa == null || idCaixa == -1) {
        throw CaixaCotrollerException('Não existe caixa aberto');
      }
      await _salvarIdCaixaSharedPreferences(idCaixa);
      return idCaixa;
    } catch (e) {
      if (e is CaixaCotrollerException) rethrow;
      throw CaixaCotrollerException('Erro ao buscar caixa aberta: $e');
    }
  }

  Future<int?> getIdCaixaFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_caixa');
  }

  Future<List<Map<String, dynamic>>> buscarPagamentosRealizadosNoCaixa(int? idCaixa) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      if (idCaixa == null) {
        try {
          idCaixa = await buscarCaixaAberto();
        } on CaixaCotrollerException catch (e) {
          throw CaixaCotrollerException(e.message);
        }
      }
      String sql = _scriptCaixa.buscarPagamentosRealizadosNoCaixa(empresa!.schema, idCaixa!);
      final resultado = await _databaseService.executeSql2(sql, schema: empresa.schema);
      print(resultado);
      return List<Map<String, dynamic>>.from(resultado);
    } catch (e) {
      throw CaixaCotrollerException('Erro ao buscar pagamentos realizados no caixa: $e');
    }
  }

  Future<Caixa?> buscarDadosDoCaixa(int idCaixa) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String sql = _scriptCaixa.buscarDadosDoCaixa(empresa!.schema, idCaixa);
      final resultado = await _databaseService.executeSql2(sql, schema: empresa.schema);
      return resultado.isNotEmpty ? Caixa.fromJson(resultado.first) : null;
    } catch (e) {
      throw CaixaCotrollerException('Erro ao buscar dados do caixa: $e');
    }
  }

  Future<void> fecharCaixa(List<Map<String, dynamic>> pagamentos, Map<String, dynamic> caixa) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();

      caixa['id_usuario_fechamento'] = "'$uidUsuario'";

      await _databaseService.fecharCaixa(schema: empresa!.schema, pagamentos: pagamentos, caixa: caixa);
    } catch (e) {
      throw CaixaCotrollerException('Erro ao fechar caixa: $e');
    }
  }
}
