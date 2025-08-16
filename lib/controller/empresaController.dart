import 'dart:convert';

import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/script.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaController {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Script script = Script();
  late SharedPreferences prefs;

  Future<List<int>> buscarIdDasEmpresasDoUsuario(String uid) async {
    final sql = script.buscarIdDasEmpresasDoUsuario(uid);
    final result = await _databaseService.executeSql2(sql, schema: 'public');
    print(result);
    // Ajuste aqui para pegar pelo alias
    return result.map((e) => e['id_empresa'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> buscarNomeFantasiaDasEmpresasDoUsuario(List<int> listIds) async {
    List<Map<String, dynamic>> listFantasias = [];
    for (var id in listIds) {
      final sql = script.buscarNomeFantasiaDasEmpresasDoUsuario(id);
      final result = await _databaseService.executeSql2(sql, schema: 'public');
      listFantasias.addAll(result.map((e) => {'id': e['id'], 'fantasia': e['fantasia']}).toList());
    }
    return listFantasias;
  }

  Future<Map<String, dynamic>> buscarDadosDaEmpresa(int id) async {
    final sql = script.buscarDadosDaEmpresa(id);
    final result = await _databaseService.executeSql2(sql, schema: 'public');
    if (result.isEmpty) throw Exception("Nenhum dado encontrado para a empresa");

    final dados = result.first;

    // Criar instância de Empresa a partir do Map
    final empresa = Empresa.fromJson(result.first);

    prefs = await SharedPreferences.getInstance();
    await prefs.setString('empresa', jsonEncode(empresa.toJson()));

    return dados;
  }


  // Buscar dados da empresa no SharedPreferences
  Future<Empresa?> getEmpresaFromSharedPreferences() async {
    try {
      prefs = await SharedPreferences.getInstance();
      String? empresaJson = prefs.getString('empresa');

      if (empresaJson != null) {
        Map<String, dynamic> empresaMap = json.decode(empresaJson);
        return Empresa.fromJson(empresaMap);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar empresa do SharedPreferences: $e');
      return null;
    }
  }
}
