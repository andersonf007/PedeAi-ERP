import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/model/unidade.dart';
import 'package:pedeai/script/script.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Unidadecontroller {



  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Script script = Script();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();

  Future<void> inserirUnidade(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    String sql = script.inserirUnidade(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao inserir unidade: ${e.toString()}');
    }
  }

  Future<List<Unidade>> listarUnidade() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da Unidade não encontrados');
      }

      String query = script.buscarListaUnidades(empresa.schema);
      // Executar query
      final response = await _databaseService.executeSqlListar(sql: query);

      if (response.isEmpty) {
        return [];
      }

      List<Unidade> unidades = response.map<Unidade>((item) {
        return Unidade.fromJson(item);
      }).toList();

      return unidades;
    } catch (e) {
      print('Erro ao listar Unidades: $e');
      return [];
    }
  }
}
