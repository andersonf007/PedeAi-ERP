// lib/controller/fornecedorController.dart

import 'package:pedeai/model/fornecedor.dart';
import 'package:pedeai/script/scriptFornecedor.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'databaseService.dart';

class FornecedorController {
  final DatabaseService _databaseService = DatabaseService();
  final ScriptFornecedor _script = ScriptFornecedor();
  final EmpresaController _empresaController = EmpresaController();

  /// Lista todos os fornecedores do schema da empresa logada
  Future<List<Fornecedor>> listarFornecedores() async {
    try {
    Empresa? empresa = await _empresaController
        .getEmpresaFromSharedPreferences();
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
    Empresa? empresa = await _empresaController
        .getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    final scriptSql = _script.buscarFornecedorPorId(id, empresa.schema);
    final data = await _databaseService.executeSql(
      scriptSql,
      schema: empresa.schema,
    );
    if (data.isEmpty) return null;
    return Fornecedor.fromJson(data.first);
  }

  /// Cadastra um novo fornecedor
  Future<void> cadastrarFornecedor(Fornecedor fornecedor) async {
    Empresa? empresa = await _empresaController
        .getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    final scriptSql = _script.inserirFornecedor(
      empresa.schema,
      fornecedor.toJson(),
    );
    try {
        await _databaseService.executeSql(scriptSql, schema: empresa.schema);
     } catch (e) {
      throw Exception('Erro ao inserir fornecedor: ${e.toString()}');
    }
  }

  /// Atualiza um fornecedor existente
  Future<void> atualizarFornecedor(Fornecedor fornecedor) async {
    Empresa? empresa = await _empresaController
        .getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    final scriptSql = _script.atualizarFornecedor(
      empresa.schema,
      fornecedor.toJson(),
    );
    try {
      await _databaseService.executeSql(scriptSql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar fornecedor: ${e.toString()}');
    }
  }

  /// Deleta um fornecedor pelo ID
  Future<void> deletarFornecedor(int id) async {
    Empresa? empresa = await _empresaController
        .getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    final scriptSql = _script.deletarFornecedor(empresa.schema, id);
    try {
        await _databaseService.executeSql(scriptSql, schema: empresa.schema);
     } catch (e) {
      throw Exception('Erro ao deletar fornecedor: ${e.toString()}');
    }
  }
}
