import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/categoria.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/script.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Categoriacontroller {

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Script script = Script();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();

  Future<void> inserirCategoria(Map<String, dynamic> dados) async {
    Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }
    dados['schema_empresa'] = empresa.schema;
    String sql = script.inserirCategoria(empresa.schema, dados);
    try {
      await _databaseService.executeSql(sql, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao inserir categoria: ${e.toString()}');
    }
  }

  Future<List<Categoria>> listarCategoria() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da categoria não encontrados');
      }

      String query = script.buscarListaCategorias(empresa.schema);
      // Executar query
      final response = await _databaseService.executeSqlListar(sql: query);

      if (response.isEmpty) {
        return [];
      }

      List<Categoria> categorias = response.map<Categoria>((item) {
        return Categoria.fromJson(item);
      }).toList();

      return categorias;
    } catch (e) {
      print('Erro ao listar categorias: $e');
      return [];
    }
  }
}