// lib/controller/fornecedorController.dart

import 'package:pedeai/model/fornecedor.dart';
import 'package:pedeai/script/scriptFornecedor.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'databaseService.dart';

class FornecedorCotrollerException implements Exception {
  String message;
  FornecedorCotrollerException(this.message);
}

class FornecedorController {
  final DatabaseService _databaseService = DatabaseService();
  final ScriptFornecedor _script = ScriptFornecedor();
  final EmpresaController _empresaController = EmpresaController();

  /// Lista todos os fornecedores do schema da empresa logada
  Future<List<Fornecedor>> listarFornecedores() async {
    try {
      Empresa? empresa = await _empresaController.getEmpresaFromSharedPreferences();
      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }
      final scriptSql = _script.buscarListaFornecedores(empresa.schema);

      final response = await _databaseService.executeSqlListar(sql: scriptSql);
      if (response.isEmpty) {
        return [];
      }
      return response.map((map) => Fornecedor.fromJson(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Busca um fornecedor por ID
  Future<Fornecedor?> buscarFornecedorPorId(int id) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    final script = ScriptFornecedor();
    final sql = script.buscarFornecedorPorId(id);

    final resultado = await _databaseService.executeSql2(sql, schema: 'public');
    if (resultado == null || resultado.isEmpty) return null;

    final dados = resultado.first;
    return Fornecedor.fromJson(dados);
  }

  /// Cadastra um novo fornecedor
  Future<int?> cadastrarFornecedor(Map<String, dynamic> fornecedorMap) async {
    Empresa? empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    try {
      return await _databaseService.cadastrarFornecedor(fornecedorMap: fornecedorMap, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao cadastrar fornecedor: ${e.toString()}');
    }
  }

  /// Atualiza um fornecedor existente
  Future<void> atualizarFornecedor(Map<String, dynamic> fornecedorMap) async {
    Empresa? empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    final scriptSql = _script.scriptAtualizarFornecedor(fornecedorMap);
    print(scriptSql);
    try {
      await _databaseService.executeSql(scriptSql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar fornecedor: ${e.toString()}');
    }
  }

  Future<void> validarExistenciaDoFornecedor(String cnpj) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    try {
      final script = _script.scriptVerificarFornecedorJaEstaCadastrado(cnpj);
      final resultado = await _databaseService.executeSql(script, schema: empresa.schema);
      if (resultado != null && resultado.isNotEmpty) {
        await verificarFornecedorJaEstaVinculadoNaEmpresa(resultado.first['id']);
      }
    }on FornecedorCotrollerException {
    rethrow;
  } catch (e) {
    throw Exception('Erro ao validar existência do fornecedor: ${e.toString()}');
  }
  }

  Future<int?> verificarFornecedorJaEstaVinculadoNaEmpresa(int id) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    final script = _script.scriptVerificarFornecedorJaEstaVinculadoNaEmpresa(empresa.schema, id);
    final resultado = await _databaseService.executeSql(script, schema: empresa.schema);
    if (resultado.first['id'] != null && resultado.isNotEmpty) {
      throw FornecedorCotrollerException('Fornecedor já está vinculado à empresa.');
    } else {
      await inserirIdFornecedorNaEmpresa(id);
    }
    return null;
  }

  Future<void> inserirIdFornecedorNaEmpresa(int idFornecedor) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    try {
      final script = _script.scriptInserirIdFornecedorNaEmpresa(empresa.schema, idFornecedor);
      await _databaseService.executeSql(script, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao vincular fornecedor à empresa: ${e.toString()}');
    }
  }
}
