import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/scriptEstoque.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Estoquecontroller {

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final ScriptEstoque script = ScriptEstoque();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();
  final Usuariocontroller usuarioController = Usuariocontroller();

  Future<void> inserirQuantidadeEstoque(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

   if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    dados['id_empresa'] = empresa.id;
    String sql = script.inserirQuantidadeEstoque(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao inserir quantidade de estoque: ${e.toString()}');
    }
  }

  Future<void> inserirMovimentacaoEstoque(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
    String? uid_usuario = await usuarioController.getUidUsuarioFromSharedPreferences();

    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    dados['uid_usuario'] = uid_usuario;
    String sql = script.inserirMovimentacaoEstoque(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao inserir movimentação de estoque: ${e.toString()}');
    }
  }

  Future<void> atualizarQuantidadeEstoque(Map<String, dynamic> dados) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      if (!dados.containsKey('id_produto_empresa') || dados['id_produto_empresa'] == null) {
        throw Exception('ID do produto é obrigatório para atualização');
      }

      String query = script.scriptAtualizarQuantidade(empresa.schema, dados);

      await _databaseService.executeSqlUpdate(sql: query, schema: empresa.schema);
    } catch (e) {
      print('Erro ao atualizar quantidade de estoque: $e');
      throw Exception('Erro ao atualizar quantidade de estoque: $e');
    }
  }
}
