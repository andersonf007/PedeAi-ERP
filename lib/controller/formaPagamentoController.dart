import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/forma_pagamento.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/scriptFormaPagamento.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormaPagamentocontroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final ScriptFormaPagamento script = ScriptFormaPagamento();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();

  Future<void> inserirFormaPagamento(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController
        .getEmpresaFromSharedPreferences();

    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    String sql = script.inserirFormaPagamento(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao inserir FormaPagamento: ${e.toString()}');
    }
  }

  Future<List<FormaPagamento>> listarFormaPagamento() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await empresaController
          .getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da FormaPagamento não encontrados');
      }

      String query = script.buscarListaFormaPagamentos(empresa.schema);
      // Executar query
      final response = await _databaseService.executeSqlListar(sql: query);

      if (response.isEmpty) {
        return [];
      }

      List<FormaPagamento> FormaPagamentos = response.map<FormaPagamento>((
        item,
      ) {
        return FormaPagamento.fromJson(item);
      }).toList();

      return FormaPagamentos;
    } catch (e) {
      print('Erro ao listar FormaPagamentos: $e');
      return [];
    }
  }

  Future<void> atualizarFormaPagamento(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController
        .getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    String sql = script.atualizarFormaPagamento(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar FormaPagamento: ${e.toString()}');
    }
  }

  Future<void> atualizarStatusFormaPagamento(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController
        .getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    String sql = script.atualizarStatusFormaPagamento(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar FormaPagamento: ${e.toString()}');
    }
  }

  Future<void> deletarFormaPagamento(int id) async {
    Empresa? empresa = await empresaController
        .getEmpresaFromSharedPreferences();

    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }

    String sql = 'DELETE FROM ${empresa.schema}.forma_pagamento WHERE id = $id';

    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao deletar FormaPagamento: ${e.toString()}');
    }
  }
}
