// lib/controller/fornecedorController.dart

import 'package:pedeai/model/cliente.dart';
import 'package:pedeai/model/fornecedor.dart';
import 'package:pedeai/script/scriptCliente.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'databaseService.dart';

class ClienteControllerException implements Exception {
  String message;
  ClienteControllerException(this.message);
}

class ClienteController {
  final DatabaseService _databaseService = DatabaseService();
  final ScriptCliente _script = ScriptCliente();
  final EmpresaController _empresaController = EmpresaController();

  /// Lista todos os clientes do schema da empresa logada
  Future<List<Cliente>> listarClientes() async {
    try {
      Empresa? empresa = await _empresaController.getEmpresaFromSharedPreferences();
      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }
      final scriptSql = _script.buscarListaClientes(empresa.schema);

      final response = await _databaseService.executeSqlListar(sql: scriptSql);
      if (response.isEmpty) {
        return [];
      }
      return response.map((map) => Cliente.fromJson(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Busca um cliente por ID
  Future<Cliente?> buscarClientePorId(int id) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    final sql = _script.buscarClientePorId(id);

    final resultado = await _databaseService.executeSql2(sql, schema: 'public');
    if (resultado == null || resultado.isEmpty) return null;

    final dados = resultado.first;
    return Cliente.fromJson(dados);
  }

  /// Cadastra um novo cliente
  Future<int?> cadastrarCliente(Map<String, dynamic> clienteMap) async {
    Empresa? empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    try {
      return await _databaseService.cadastrarCliente(clienteMap: clienteMap, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao cadastrar cliente: ${e.toString()}');
    }
  }

  /// Atualiza um cliente existente
  Future<void> atualizarCliente(Map<String, dynamic> clienteMap) async {
    Empresa? empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    final scriptSql = _script.scriptAtualizarCliente(clienteMap);
    print(scriptSql);
    try {
      await _databaseService.executeSql(scriptSql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar fornecedor: ${e.toString()}');
    }
  }

  Future<void> validarExistenciaDoCliente(String cpf) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    try {
      final script = _script.scriptVerificarClienteJaEstaCadastrado(cpf);
      final resultado = await _databaseService.executeSql(script, schema: empresa.schema);
      if (resultado != null && resultado.isNotEmpty) {
        await verificarClienteJaEstaVinculadoNaEmpresa(resultado.first['id']);
      }
    }on ClienteControllerException {
    rethrow;
  } catch (e) {
    throw Exception('Erro ao validar existência do fornecedor: ${e.toString()}');
  }
  }

  Future<int?> verificarClienteJaEstaVinculadoNaEmpresa(int id) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    final script = _script.scriptVerificarClienteJaEstaVinculadoNaEmpresa(empresa.schema, id);
    final resultado = await _databaseService.executeSql(script, schema: empresa.schema);
    if (resultado.first['id'] != null && resultado.isNotEmpty) {
      throw ClienteControllerException('Cliente já está vinculado à empresa.');
    } else {
      await inserirIdClienteNaEmpresa(id);
    }
    return null;
  }

  Future<void> inserirIdClienteNaEmpresa(int idCliente) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    try {
      final script = _script.scriptInserirIdClienteNaEmpresa(empresa.schema, idCliente);
      await _databaseService.executeSql(script, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao vincular cliente à empresa: ${e.toString()}');
    }
  }

Future<int?> buscarIdClientePorCpf(String cpf) async {
    final empresa = await _empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');
    final sql = _script.scriptBuscaridClientePeloCpf(empresa.schema, cpf);

    final resultado = await _databaseService.executeSql2(sql, schema: empresa.schema);
    if (resultado == null || resultado.isEmpty) return null;

    final dados = resultado.first;
    return dados['id'] as int?;
  }
}
